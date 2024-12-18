import subprocess
import threading
import time
from get_latest_run_id import get_latest_run_id

# Function to start MLflow UI
def start_mlflow_ui():
    subprocess.run(["mlflow", "ui", "--host", "0.0.0.0"], check=True)
    # subprocess.run(["mlflow", "ui"], check=True)

# Function to serve the latest model
def serve_latest_model():
    time.sleep(5)  # Allow time for the training process to finish
    run_id = get_latest_run_id()
    if run_id:
        model_path = f"mlruns/0/{run_id}/artifacts/model"
        subprocess.run(["mlflow", "models", "serve", "-m", model_path, "--host", "0.0.0.0", "--port", "1234"], check=True)
    else:
        print("No model found to serve.")

if __name__ == "__main__":
    # Train the model
    subprocess.run(["python", "train.py"], check=True)

    # Start MLflow UI and serve model concurrently
    threading.Thread(target=start_mlflow_ui).start()
    threading.Thread(target=serve_latest_model).start()
