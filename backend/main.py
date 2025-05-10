      from fastapi import FastAPI, HTTPException
      from fastapi.responses import HTMLResponse
      from fastapi.middleware.cors import CORSMiddleware
      from fastapi.staticfiles import StaticFiles
      import folium
      import os
      app = FastAPI()

      # 1) CORS (pode restringir em produção)
      app.add_middleware(
          CORSMiddleware,
          allow_origins=["*"],  # Permite acessar de qualquer origem (em produção restrinja isso)
          allow_methods=["GET", "POST", "OPTIONS"],
          allow_headers=["*"],
      )

      # 2) Verifique se o diretório 'static' existe, e se não, crie-o
      static_dir = "static"
      if not os.path.exists(static_dir):
          os.mkdir(static_dir)

      # 3) Servir arquivos estáticos (mapa HTML)
      app.mount("/static", StaticFiles(directory=static_dir), name="static")

      # 4) Endpoint para gerar o mapa
      @app.get("/get-map/")
      async def get_map():
          try:
              # Coordenadas de Recife, Pernambuco
              lat, lon = -8.0476, -34.8770  # Recife, Pernambuco
              m = folium.Map(location=[lat, lon], zoom_start=10)

              # Adicionando alguns pontos no mapa
              folium.Marker([-8.0476, -34.8770], popup="Recife").add_to(m)
              folium.Marker([-7.9696, -34.7915], popup="Olinda").add_to(m)

              # Salva o mapa em um arquivo HTML no diretório estático
              map_path = os.path.join(static_dir, "map.html")
              m.save(map_path)

              # Verifique se o arquivo foi salvo corretamente
              if not os.path.exists(map_path):
                  raise HTTPException(500, f"Erro ao salvar o mapa em {map_path}")

              # Retorna a URL do mapa para o frontend
              return HTMLResponse(content=f"<html><body><iframe src='/static/map.html' width='100%' height='600px'></iframe></body></html>", status_code=200)
          except Exception as e:
              raise HTTPException(500, f"Erro ao gerar mapa: {e}")
