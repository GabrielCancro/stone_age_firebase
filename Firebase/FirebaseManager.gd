extends Node

var db:FirebaseDatabase
var ref:FirebaseReference
var initialized = false

signal complete(result)

var firebase_config = {
	"apiKey": "AIzaSyDwl2xTkoIky9w0mPXkkFheppcVskrPzZU",  # set somewhere only if using auth
	"authDomain": "moledata-74872.firebaseapp.com",
	"databaseURL": "https://moledata-74872-default-rtdb.firebaseio.com",
	"projectId": "moledata-74872",
	"storageBucket": "moledata-74872.appspot.com",
	"messagingSenderId": "491701428697",
	"appId": "1:491701428697:web:25b0320595e6191d8e39c8"
}

func _init():
	if initialized: return
	firebase.initialize_app(firebase_config)
	db = firebase.database()
	initialized = true
	
func get_data(table):
	_init()
	ref = db.get_reference_lite("stone_age_fb/"+table)
	ref.fetch()
	var result = yield( ref, "complete_fetch" )
	emit_signal("complete",result)

func set_data(table,k,v):
	_init()
	ref = db.get_reference_lite("stone_age_fb/"+table)
	var result = yield(ref.update({k:v}), "completed")
	emit_signal("complete",result)
