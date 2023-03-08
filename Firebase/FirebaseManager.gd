extends Node

var db:FirebaseDatabase
var auth:FirebaseAuth
var ref:FirebaseReference
var initialized = false

var USERS = null
var DATA = null

signal complete_pull
signal complete_push
signal complete_remove
signal complete_login

#var firebase_config = {
#	"apiKey": "AIzaSyDwl2xTkoIky9w0mPXkkFheppcVskrPzZU",  # set somewhere only if using auth
#	"authDomain": "moledata-74872.firebaseapp.com",
#	"databaseURL": "https://moledata-74872-default-rtdb.firebaseio.com",
#	"projectId": "moledata-74872",
#	"storageBucket": "moledata-74872.appspot.com",
#	"messagingSenderId": "491701428697",
#	"appId": "1:491701428697:web:25b0320595e6191d8e39c8"
#}

var firebase_config = {
  "apiKey": "AIzaSyAam2xvP1nE_35daMjYSTjegrw3xppY2DU",
  "authDomain": "bearmolegames.firebaseapp.com",
  "databaseURL": "https://bearmolegames-default-rtdb.firebaseio.com",
  "projectId": "bearmolegames",
  "storageBucket": "bearmolegames.appspot.com",
  "messagingSenderId": "254964731747",
  "appId": "1:254964731747:web:eb0ac9b48759ec73798d56",
  "measurementId": "G-XDZT86HGJ7"
}

func init():
	if initialized: return
	firebase.initialize_app(firebase_config)
	db = firebase.database()
	auth = firebase.auth()
	initialized = true

func pull_users():
	ref = db.get_reference_lite("users/")
	ref.fetch()
	USERS = yield( ref, "complete_fetch" )
	if(USERS):
		emit_signal("complete_pull")
#		print("< PULL DATA: ",JSON.print(DATA, "\t"))
	else: 
		yield(get_tree().create_timer(3),"timeout")
#		print("re-conecting...")
		pull_data()
		
func pull_data():
	ref = db.get_reference_lite("stone_age_fb/")
	ref.fetch()
	DATA = yield( ref, "complete_fetch" )
	if(DATA):
		emit_signal("complete_pull")
#		print("< PULL DATA: ",JSON.print(DATA, "\t"))
	else: 
		yield(get_tree().create_timer(3),"timeout")
#		print("re-conecting...")
		pull_data()

func get_data():
	return DATA
	
func push_data(path):
	ref = db.get_reference_lite("stone_age_fb/"+path)
	var part_data = DATA
	for k in path.split("/"): part_data = part_data[k]
	var result = yield(ref.update(part_data), "completed")
	emit_signal("complete_push")

func push_var(path,k,v):
	ref = db.get_reference_lite("stone_age_fb/"+path)
	var result = yield(ref.update({k:v}), "completed")
	emit_signal("complete_push")
#	print("> PUSH VAR: ",path,"  >  ",{k:v})

func delete_path(path):
	ref = db.get_reference_lite("stone_age_fb/"+path)
	var result = yield(ref.remove(), "completed")
	emit_signal("complete_remove")
#	print("> PUSH VAR: ",path,"  >  ",{k:v})

func check_user_exists(_name : String) -> bool:
	return _name in FM.DATA.users

func login(username,password):
	if !USERS || !username in USERS: 
		emit_signal("complete_login",{ "success":false, "error":{"code":"auth/non-existent-user"}})
		return false
	var data = auth.sign_in_with_email_and_password(USERS[username].mail,password)
	var result = yield(auth,"on_finish_login_task")
	emit_signal("complete_login",result)
