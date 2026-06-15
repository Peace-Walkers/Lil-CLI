import socket

def parse_http(raw_request: str) -> dict:
    parts = raw_request.split("\r\n\r\n")
    head_part = parts[0]
    
    body = ""
    if len(parts) > 1:
        body = parts[1]
        
    lines = head_part.split("\r\n")
    
    request_line = lines[0].split(" ")
    method = request_line[0]
    path = request_line[1]
    
    headers = {}
    
    i = 1
    while i < len(lines):
        header_line = lines[i]
        header_parts = header_line.split(": ")
        
        if len(header_parts) == 2:
            headers[header_parts[0]] = header_parts[1]
            
        i += 1
        
    result = {
        "method": method,
        "path": path,
        "headers": headers,
        "body": body
    }
    
    return result

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) 
    server.bind(("0.0.0.0", 8080))
    server.listen(5)
    
    print("Serveur HTTP démarré sur http://localhost:8080")
    
    while True:
        client_socket, client_address = server.accept()
        
        req_bytes = client_socket.recv(4096)
        if not req_bytes:
            client_socket.close()
            continue
            
        req = req_bytes.decode('utf-8')
        
        parsed = parse_http(req)
        print(parsed)
        
        body = "<h1>Salut de la part de Python !</h1>"
        response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 38\r\n\r\n"
        
        client_socket.sendall(response.encode('utf-8'))
        client_socket.sendall(body.encode('utf-8'))
        
        client_socket.close()

if __name__ == "__main__":
    main()
