extends Node

var http = null
signal complete(time)

func init():
	http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_request_completed")
	get_tree().get_current_scene().add_child(http)

func get_time():
	http.request(HTTPClient.METHOD_GET,"https://timeapi.io/api/Time/current/zone?timeZone=America/Argentina/Buenos_Aires")
	return self

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json)
	var datetime = json.result
	datetime.second = datetime.seconds
	var unix_time = OS.get_unix_time_from_datetime(datetime)
	emit_signal("complete",unix_time)
