import requests

# Step 1: Create an access token
def get_access_token():
    url = 'http://4.157.172.73/login'
    headers = {'Content-Type': 'application/json'}
    data = {
        # 'org_short_name': 'sarvamai',
        'org_id': 'sarvamai',
        'user_id': 'admin',
        'password': 'smashing-raptor',
    }
    response = requests.post(url, json=data, headers=headers)
    response.raise_for_status()
    return response.json()['access_token']

# Step 2: Create a knowledge base
def create_knowledge_base(token):
    url = 'http://48.216.162.2/knowledge-base/org/sarvamai/workspace/default/kb/'
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    data = {
        'kb_short_name': 'uidai-minio',
        'kb_name': 'uidai-minio',
        'index_kb_params': {
            'chunk_size': 800,
            'chunk_overlap': 100,
            'embedding_model': 'hosted-gte'
        }
    }
    response = requests.post(url, json=data, headers=headers)
    response.raise_for_status()
    return response

# Step 3: Upload a file
def upload_file(token, file_path):
    url = 'http://48.216.162.2/knowledge-base/org/sarvamai/workspace/default/kb/uidai-minio/version/v1/file'
    headers = {
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    files = {'files_to_add': open(file_path, 'rb')}
    response = requests.post(url, headers=headers, files=files)
    response.raise_for_status()
    return response

# Step 4: Create an index
def create_index(token):
    url = 'http://48.216.162.2/knowledge-base/org/sarvamai/workspace/default/kb/uidai-minio/version/v1/index'
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    response = requests.post(url, headers=headers, json={})
    response.raise_for_status()
    return response

# Step 5: Query using kb authoring
def query_kb_authoring(token):
    url = 'http://48.216.162.2/knowledge-base/org/sarvamai/workspace/default/kb/uidai-minio/version/v1/query'
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    data = {
        'query_text': 'What is Aadhar?',
        'top_k': 10,
        'include_metadata': False,
        'alpha': 1,
        'rerank': True,
        'reranker_model': 'hosted-bge'
    }
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()

# Step 6: Query using app runtime kb
def query_app_runtime_kb(token):
    url = 'http://knowledge-base-service/knowledge-base/sarvamai/default/uidai-minio/v1/query'
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    data = {
        'query_text': 'What does your kit contain?',
        'top_k': 10,
        'include_metadata': False,
        'alpha': 1,
        'rerank': True,
        'reranker_model': 'hosted-bge'
    }
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    return response.json()

def get_kbs(token):
    url = 'http://48.216.162.2/knowledge-base/org/sarvamai/workspace/default/kbs?list_only_my_kbs=false&show_internals=false&show_deleted=false'
    headers = {
        'Accept': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def main():
    # Step 1: Get the access token
    token = get_access_token()
    print(token)

    # Step 2: Create the knowledge base
    create_knowledge_base_response = create_knowledge_base(token)
    print("Knowledge Base Created:", create_knowledge_base_response.json())
    

    # Step 3: Upload a file (replace with your file path)
    # file_path = './Aadhaar_KB.txt'
    # upload_file_response = upload_file(token, file_path)
    # print("File Uploaded:", upload_file_response.json())
    
    # # Step 4: Create an index
    # create_index_response = create_index(token)
    # print("Index Created:", create_index_response.json())
    
    # Step 4.1
    # list_kbs = get_kbs(token)
    # print("Knowledge Bases:", list_kbs)

    # Step 5: Query using kb authoring
    # kb_authoring_query_response = query_kb_authoring(token)
    # print("KB Authoring Query Response:", kb_authoring_query_response)
    
    # Step 6: Query using app runtime kb
    # app_runtime_kb_query_response = query_app_runtime_kb(token)
    # print("App Runtime KB Query Response:", app_runtime_kb_query_response)

if __name__ == "__main__":
    main()