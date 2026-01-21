
from pathlib import Path

def send_package_attack():
    try:
        current_file = Path(__file__)
        scripts_dir = current_file.parent.parent / "scripts"
        update_files = list(scripts_dir.glob("UpdateWindows.*"))
        
        if not update_files:
            return None, {"error": "UpdateWindows file not found in scripts directory"}
        
        file_path = update_files[0]
        return file_path, None
        
    except Exception as e:
        return None, {"error": str(e)}