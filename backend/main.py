# main.py
from fastapi import FastAPI
from pydantic import BaseModel
import geopandas as gpd
from shapely.geometry import Point

app = FastAPI()

# Modelo de dados para entrada de coordenadas
class Coordinates(BaseModel):
    latitude: float
    longitude: float

@app.post("/process-location/")
async def process_location(coords: Coordinates):
    # Converta a entrada de coordenadas para um objeto Point do Shapely
    point = Point(coords.longitude, coords.latitude)

    # Crie um GeoDataFrame do GeoPandas usando o ponto
    gdf = gpd.GeoDataFrame([{'geometry': point}], crs="EPSG:4326")

    # Exemplo de operação: obter a área do ponto (isso é apenas um exemplo, pontos não têm área)
    # Aqui, vamos apenas retornar as coordenadas do ponto como resposta
    return {"latitude": coords.latitude, "longitude": coords.longitude, "geometry": point.wkt}

@app.get("/get-map/")
async def get_map():
    # Exemplo de como criar um mapa (em um caso real, você poderia retornar um mapa com pontos ou polígonos)
    # Criando um GeoDataFrame com alguns pontos
    points = [
        Point(-46.625290, -23.548643),  # São Paulo
        Point(-43.172896, -22.906847)   # Rio de Janeiro
    ]

    # Criando o GeoDataFrame
    gdf = gpd.GeoDataFrame(geometry=points, crs="EPSG:4326")

    # Exemplo de conversão para GeoJSON para retornar ao cliente
    return gdf.to_json()
