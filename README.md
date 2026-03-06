----- Code Packaging -------

aws-lambda-project/
│
├── src/
│   ├── lambda_function.py
│   └── utils.py
│
├── requirements.txt
│
├── build/
│
├── layer/
│   └── python/
│
├── tests/
│   └── test_lambda.py
│
├── events/
│   └── event.json
│
├── scripts/
│   └── build.sh
│
└── README.md


1.Create the folder structure 
2.Add the source code into lambda_function.py 
3.Enable the venv and install the required modules
# Create venv ----
	python -m venv venv 
# activate the venv 
	venv/scripts/activate 
# requests | boto3 
	pip install requests
	pip install boto3
4.Modify the code and validate the changes .
# Freeze the requirements 
    pip freeze > requirements.txt
# Deployment into AWS Lambda
5.Bundle the package to deploy into AWS Lambda 
    pip install -r requirements.txt -t /build 
# Zip the package (build folder)
    cd build
    Compress-Archive -Path * -DestinationPath ../lambda_deployment.zip



# Project Structure with Layer 
aws-lambda-project/
│
├── src/
│   └── lambda_function.py
│
├── requirements.txt
│
├── layer/
│   └── python/
│
├── build/
│
└── layer.zip
	

# python folder inside Layer 
    cd layer
    mkdir python
# Install the dependencies
    pip install -r requirements.txt -t layer/python
# zip the layer folder 
    cd layer
    Compress-Archive -Path * -DestinationPath ../layer.zip
    # Structure 
    layer.zip
    └── python/
        ├── requests/
        ├── urllib3/
# upload to aws lambda > Layers 

# Simply add the lamda_function.py into the function and add the layers and run it .