# app.py

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import geopandas as gpd
import contextily as ctx
import matplotlib.pyplot as plt
import io
from shapely.geometry import Point

app = FastAPI()

# 1) CORS (pode restringir em produção)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET","POST","OPTIONS"],
    allow_headers=["*"],
)

# CRS padrão do GeoServer e shapefile
DEFAULT_CRS = "EPSG:4326"
WEB_MERCATOR = "EPSG:3857"

# Carrega em memória (ou use cache!) o GeoDataFrame dos imóveis
# Substitua pelo shapefile/export GeoJSON do SICAR (ou seu WFS local)
gdf_car = gpd.read_file("data/car_areas.shp").to_crs(WEB_MERCATOR)

class Coordinates(BaseModel):
    latitude: float
    longitude: float

@app.post("/process-location/")
async def process_location(coords: Coordinates):
    try:
        point = Point(coords.longitude, coords.latitude)
        return {
            "latitude": coords.latitude,
            "longitude": coords.longitude,
            "wkt": point.wkt
        }
    except Exception as e:
        raise HTTPException(500, f"Erro no processamento: {e}")

@app.get("/get-map/")
async def get_map():
    try:
        # Exemplo simples de GeoJSON com dois pontos
        pts = [
            Point(-46.625290, -23.548643),  # São Paulo
            Point(-43.172896, -22.906847)   # Rio de Janeiro
        ]
        gdf = gpd.GeoDataFrame(geometry=pts, crs=DEFAULT_CRS)
        return gdf.to_crs(DEFAULT_CRS).__geo_interface__
    except Exception as e:
        raise HTTPException(500, f"Erro ao gerar mapa: {e}")

@app.get("/maps/beneficiary/{cod_imovel}")
async def map_beneficiary(cod_imovel: str):
    """
    Recorta o imóvel identificado por cod_imovel, plota com Contextily e
    retorna um PNG pronto para exibir no Flutter.
    """
    try:
        # 1) Filtra o GeoDataFrame pelo código do imóvel
        subset = gdf_car[gdf_car["cod_imovel"].astype(str) == cod_imovel]
        if subset.empty:
            raise HTTPException(status_code=404, detail="Beneficiário não encontrado")

        # 2) Plota em Mercator
        ax = subset.plot(figsize=(6, 6), alpha=0.6, edgecolor="black")
        # Adiciona basemap (OSM ou Stamen)
        ctx.add_basemap(ax, source=ctx.providers.Stamen.TerrainBackground)
        ax.axis("off")

        # 3) Salva em buffer
        buf = io.BytesIO()
        plt.savefig(buf, format="png", bbox_inches="tight", pad_inches=0)
        plt.close()

        # 4) Retorna binário PNG
        return Response(content=buf.getvalue(), media_type="image/png")

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao gerar mapa: {e}")
