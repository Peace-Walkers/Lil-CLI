import socket

body = b"<h1>Salut de la part de LiLang !</h1>"
response = b"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 37\r\n\r\n"

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

server.bind(("0.0.0.0", 8080))
server.listen(100) 

print("Serveur HTTP démarré sur http://localhost:8080")

try:
    while True:
        client, addr = server.accept()
        
        try:
            req = client.recv(1024)
            
            client.sendall(response)
            client.sendall(body)
            
        finally:
            client.close()

except KeyboardInterrupt:
    server.close()
    print("\nServeur arrêté proprement.")
