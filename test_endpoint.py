import requests

# Define the URL
url = "http://127.0.0.1:1234/invocations"

# Define the JSON payload
payload = {
    "dataframe_split": {
        "columns": [
            "fixed acidity", "volatile acidity", "citric acid", 
            "residual sugar", "chlorides", "free sulfur dioxide", 
            "total sulfur dioxide", "density", "pH", "sulphates", "alcohol"
        ],
        "data": [[6.2, 0.66, 0.48, 1.2, 0.029, 29, 75, 0.98, 3.33, 0.39, 12.8]]
    }
}

# Send POST request
response = requests.post(
    url,
    json=payload,  # Automatically converts the payload to JSON
    headers={"Content-Type": "application/json"}
)

# Check the response
if response.status_code == 200:
    print("Response received:", response.json())
else:
    print(f"Request failed with status code {response.status_code}: {response.text}")
