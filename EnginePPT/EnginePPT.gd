extends Node


# 사용가능한지 여부
var workable:= false
# 현재 보고있는 페이지 (index)
var current_page:int = 0 setget _current_page_set
func _current_page_set(value:int):
	if current_page != value:
		move_page_to(value)
	current_page = value
# 등록된 모든 페이지 (이름순, sort)
var page_list: = []


func _ready():
	# 시작과 동시에 페이지 폴더 파일리스트를 읽어 페이지 리스트 생성
	var dir:= Directory.new()
	if not dir.dir_exists('res://EnginePPT/Pages'):
		printerr('No pages found.')
		return
	dir.open('res://EnginePPT/Pages')
	var err:= dir.list_dir_begin(true, true)
	if err == OK:
		var _filename:= dir.get_next()
		while _filename:
			page_list.push_back(_filename)
			_filename = dir.get_next()
		page_list.sort()
	dir.list_dir_end()
	if page_list.size():
		self.current_page = 0
		workable = true
	else: printerr('No pages found.')


func _input(event):
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_LEFT):
			print_debug('이전 단계')
		if Input.is_key_pressed(KEY_RIGHT):
			print_debug('다음 단계')
		if Input.is_key_pressed(KEY_HOME):
			self.current_page = 0
		if Input.is_key_pressed(KEY_END):
			self.current_page = page_list.size() - 1
		if Input.is_key_pressed(KEY_PAGEUP):
			self.current_page = clamp(current_page - 1, 0, page_list.size() - 1)
		if Input.is_key_pressed(KEY_PAGEDOWN):
			self.current_page = clamp(current_page + 1, 0, page_list.size() - 1)


# 특정 페이지로 이동
func move_page_to(index:int):
	if workable:
		print_debug('다음 페이지: ', page_list[index])
