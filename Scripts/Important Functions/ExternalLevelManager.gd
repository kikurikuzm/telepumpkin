extends Node

static var dailyServerConnection:HTTPClient
static var loadedDailyLevel:PackedScene = null

var connectedToDailyLevelServer:bool = false

const DAILY_SERVER_ADDRESS := "http://localhost"
const DAILY_SERVER_ENDPOINT := "/daily"

signal establishedConnectionToDailyServer
signal downloadedDailyLevel

func _ready() -> void:
	dailyServerConnection = HTTPClient.new()
	establishDailyServerConnection()

func isConnectedToDailyServer() -> bool:
	return connectedToDailyLevelServer

func establishDailyServerConnection() -> void:
	var err = dailyServerConnection.connect_to_host(DAILY_SERVER_ADDRESS, 5000)
	if err != OK:
		print_debug("Daily-Server: Unable to connect. Err: %s" % error_string(err))
		return
	
	dailyServerConnection.poll()
	
	while dailyServerConnection.get_status() == HTTPClient.STATUS_CONNECTING or dailyServerConnection.get_status() == HTTPClient.STATUS_RESOLVING:
		dailyServerConnection.poll()
		await get_tree().process_frame
	
	if dailyServerConnection.get_status() != HTTPClient.STATUS_CONNECTED:
		print_debug("Daily-Server: Failed to connect. Err: %d" % dailyServerConnection.get_status())
		return
	
	establishedConnectionToDailyServer.emit()
	connectedToDailyLevelServer = true

func getDailyLevel() -> PackedScene:
	var dailyLevel:PackedScene = null
	var serverResponse:PackedByteArray = PackedByteArray()
	
	#dailyServerConnection.request("localhost:5000/daily")
	#var response = await dailyServerConnection.request_completed
	#response = (response[3] as PackedByteArray)
	#
	#if response[1] != 200:
		#print_debug("Bad level request. Something went wrong!")
		#return null
	
	var err = dailyServerConnection.request(HTTPClient.METHOD_GET, DAILY_SERVER_ENDPOINT, [])
	if err != OK:
		print_debug("Daily-Server: Bad request. Err: %s" % error_string(err))
		return dailyLevel
	
	dailyServerConnection.poll()
	while dailyServerConnection.get_status() == HTTPClient.STATUS_REQUESTING:
		dailyServerConnection.poll()
		await get_tree().process_frame
	
	while dailyServerConnection.get_status() == HTTPClient.STATUS_BODY:
		var chunk:PackedByteArray = PackedByteArray()
		
		chunk = dailyServerConnection.read_response_body_chunk()
		if chunk.size() == 0:
			await get_tree().process_frame
		else:
			serverResponse += chunk
	
	var userDir = DirAccess.open("user://")
	if !userDir.dir_exists("daily"): userDir.make_dir("daily")
	
	var userData:FileAccess = FileAccess.open("user://daily/today.tscn", FileAccess.WRITE)
	userData.store_buffer(serverResponse)
	userData.close()
	
	loadedDailyLevel = load("user://daily/today.tscn")
	
	downloadedDailyLevel.emit()
	
	return dailyLevel
