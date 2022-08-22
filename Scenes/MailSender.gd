extends HTTPRequest

var URL = "https://aquiyahoraatulado.org.ar/CRT/sendMail.php"
var DATA = ""

func _ready():
	connect("request_completed", self, "_http_request_completed")
	DATA+="?from=validation@games.fb"
	DATA+="&to=critersoft@gmail.com"
	DATA+="&subject=Validación de usuario"
	DATA+="&message=su codigo es 123123"
	DATA+="&send=true"
	DATA = DATA.replace(" ","%20")
	send()

func send():
	print(URL+DATA)
	var error = request(URL+DATA, [], true, HTTPClient.METHOD_GET, "")
	if error != OK: 
		push_error("An error occurred in the HTTP request.")
		print("ERROR!!")

func _http_request_completed(result, response_code, headers, body):
	print(body.get_string_from_utf8())
	var response = parse_json(body.get_string_from_utf8())
	print("HTTP REQUEST SENDING MAIL")
	print(response)
