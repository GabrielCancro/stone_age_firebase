extends Node

var http = null
signal complete(time)

func init():
	http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_request_completed")
	get_tree().get_current_scene().add_child(http)

func get_time():
	http.request("http://worldclockapi.com/api/json/est/now")
	return self

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var time = floor( (json.result.currentFileTime - 133040205110000000 ) / 10000000 )
	emit_signal("complete",time)
