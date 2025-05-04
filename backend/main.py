from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import geopandas as gpd
from shapely.geometry import Point
import json

app = FastAPI()

# CRS padrão
default_crs = "EPSG:4326"

# Modelo de dados para entrada de coordenadas
class Coordinates(BaseModel):
    latitude: float
    longitude: float

@app.post("/process-location/", response_class=JSONResponse)
async def process_location(coords: Coordinates):
    try:
        point = Point(coords.longitude, coords.latitude)
        gdf = gpd.GeoDataFrame([{'geometry': point}], crs=default_crs)
        return {
            "latitude": coords.latitude,
            "longitude": coords.longitude,
            "wkt": point.wkt
        }
    except Exception as e:
        raise HTTPException(500, f"Erro no processamento: {e}")

@app.get("/get-map/", response_class=JSONResponse)
async def get_map():
    try:
        points = [
            Point(-46.625290, -23.548643),  # São Paulo
            Point(-43.172896, -22.906847)   # Rio de Janeiro
        ]
        gdf = gpd.GeoDataFrame(geometry=points, crs=default_crs)
        geojson_str = gdf.to_json()
        geojson = json.loads(geojson_str)
        return geojson
    except Exception as e:
        raise HTTPException(500, f"Erro ao gerar mapa: {e}")
