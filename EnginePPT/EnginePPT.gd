extends Node


# 사용가능한지 여부
var workable:= false
# 현재 보고있는 페이지 (index)
var current_page:int = -1 setget _current_page_set
func _current_page_set(value:int):
	value = clamp(value, 0, page_list.size() - 1)
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
		workable = true
		self.current_page = 0
	else: printerr('No pages found.')


func _input(event):
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_LEFT): # prev act
			$Page/Current.move_act_step_to(-1)
		if Input.is_key_pressed(KEY_RIGHT): # next act
			$Page/Current.move_act_step_to(1)
		if Input.is_key_pressed(KEY_HOME): # go to very first page
			self.current_page = 0
		if Input.is_key_pressed(KEY_END): # go to very last page
			self.current_page = page_list.size() - 1
		if Input.is_key_pressed(KEY_PAGEUP): # go to prev page
			self.current_page = current_page - 1
		if Input.is_key_pressed(KEY_PAGEDOWN): # go to next page
			self.current_page = current_page + 1


# 특정 페이지로 이동
func move_page_to(index:int):
	if workable:
		var children:= $Page/Current.get_children()
		var target_page = load('res://EnginePPT/Pages/%s' % [page_list[index]])
		$Page/Current.current_page = target_page.instance()
		$Page/Current.add_child($Page/Current.current_page)
		$Page/Current.current_act_index = 0
		for child in children:
			child.queue_free()
