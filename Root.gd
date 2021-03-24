extends Node
# 현재 씬 내 애니메이션 순번
var animation_stack:=0
# 준비된 씬의 수 (자동으로 산정됨)
var max_scene_count:=0
# 현재 보고 있는 씬
var current_scene_id:=0
# 현재 네비게이터 상태
var is_navigator_open:=false
# 다음에 보여질 씬
var cached_next_scene:PageScene

onready var current_scene:=$'/root/Main/CurrentScene'
onready var cache_scene:=$'/root/Main/CacheNextScene'

func _ready():
	if not OS.is_debug_build(): # 릴리즈시 전체화면
		OS.window_fullscreen = true
	check_pages()
	if max_scene_count > 0:
		move_to_scene(0)
	else:
		printerr('페이지 구성 없음')
		get_tree().quit()
	yield(get_tree().create_timer(0),"timeout")
	for current in current_scene.get_children():
		current.set_process_input(true)

# pages 폴더 안에 얼마나 구성되어있나
func check_pages():
	var dir:=Directory.new()
	if dir.open('res://pages') == OK:
		dir.list_dir_begin(true)
		var file_name:=dir.get_next()
		while file_name:
			if file_name.find('.tscn') + 1:
				max_scene_count += 1
			file_name=dir.get_next()
		dir.list_dir_end()
	else:
		printerr('pages 열람 실패')

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC로 PPT 종료
		get_tree().quit()
	if event.is_action_pressed("ppt_page_prev"): # 이전 씬
		previous_scene()
	if event.is_action_pressed("ppt_page_next"): # 다음 씬
		next_scene()
	if event.is_action_pressed("ppt_page_front"): # 제일 처음 씬으로
		move_to_scene(0)
	if event.is_action_pressed("ppt_page_back"): # 마지막 씬으로
		move_to_scene(max_scene_count - 1)
	if event.is_action_pressed("ui_navigation_toggle"): # 상단 네비게이터 토글
		toggle_navigator()

func previous_scene():
	var precalced:=current_scene_id-1
	if precalced >= 0:
		move_to_scene(precalced)
	else:
		printerr('이전 씬 없음: (%d-1)/%d'%[current_scene_id,max_scene_count-1])

func next_scene():
	var precalced:=current_scene_id+1
	if precalced < max_scene_count:
		move_to_scene(precalced)
	else:
		printerr('다음 씬 없음: (%d+1)/%d'%[current_scene_id,max_scene_count-1])

func move_to_scene(page_id:int):
	print_debug('이 장면으로 이동:', page_id)
	for current in current_scene.get_children():
		current_scene.remove_child(current)
		current._user_command_exit()
	current_scene_id = page_id
	for cached in cache_scene.get_children():
		if cached.name == '%03d'%page_id:
			# 준비된 씬으로 변경처리
			cached_next_scene=cached
		else: # 나머지 삭제
			cache_scene.remove_child(cached)
			cached.force_remove=true
			cached._user_command_exit()
	# 캐시된 씬 중에 페이지가 없던 경우
	if current_scene.get_child_count() < 1:
		cached_next_scene=null
		load_target_scene([page_id],true)
	# 보통 다음 씬으로 이어지기 때문에 그 다음씬은 생성시도함
	var precalced:=page_id+1
	if precalced < max_scene_count:
		var thread:=Thread.new()
		if thread.start(self,'load_target_scene',[thread,precalced]) != OK:
			load_target_scene([precalced])
			thread.wait_to_finish()

var mutex:=Mutex.new()
# 다음 씬 불러오기
func load_target_scene(data_arr:Array,just_now:=false):
	var catch_thread:Thread = data_arr.pop_front() if data_arr[0] is Thread else null
	var target_id = data_arr.pop_back()
	mutex.lock()
	var target_scene=load('res://pages/%03d.tscn'%target_id).instance()
	mutex.unlock()
	if target_scene:
		if just_now: # 지금 바로 변경해주세요
			current_scene.add_child(target_scene)
			target_scene.show()
			target_scene.set_process_input(true)
		else: # 일반적인 경우
			cache_scene.add_child(target_scene)
	else:
		printerr('씬 불러오기 실패: ',target_id)
	if catch_thread:
		catch_thread.wait_to_finish()

# 이전 씬과 이후 씬 교체
# 페이지 삭제될 때 불러와짐
func swap_scenes(before:PageScene):
	if not before.force_remove and cached_next_scene:
		cache_scene.remove_child(cached_next_scene)
		current_scene.add_child(cached_next_scene)
		cached_next_scene.show()
		cached_next_scene.set_process_input(true)

func toggle_navigator():
	is_navigator_open = !is_navigator_open
	print_debug('네비게이션 토글: ',is_navigator_open)
