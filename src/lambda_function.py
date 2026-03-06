import json
import requests

def lambda_handler(event,context):
    
     api_url = "https://dog.ceo/api/breeds/image/random"
     response = requests.get(api_url, timeout=10)
     response.raise_for_status()
     image_url = response.json()["message"]

    
     print("Received event: " + json.dumps(event, indent=2))
    
     return {
        'statusCode': 200,
        'body': json.dumps(image_url)
      }
    

if __name__ == "__main__":
    # Simulate an event for testing
     
    print("Output : ", lambda_handler(None, None))