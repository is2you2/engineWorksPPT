extends Node

# 준비된 씬의 수 (자동으로 산정됨)
var max_scene:int
# 현재 네비게이터 상태
var is_navigator_open:=false

func _ready():
	if not OS.is_debug_build(): # 릴리즈시 전체화면
		OS.window_fullscreen = true

func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC로 PPT 종료
		get_tree().quit()
	# 씬 내 이전 애니메이션
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		previous_animation_stack()
	# 씬 내 다음 애니메이션
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		next_animation_stack()
	if event.is_action_pressed("ui_page_up"): # 이전 씬
		previous_scene()
	if event.is_action_pressed("ui_page_down"): # 다음 씬
		next_scene()
	if event.is_action_pressed("ui_home"): # 제일 처음 씬으로
		move_to_scene(0)
	if event.is_action_pressed("ui_end"): # 마지막 씬으로
		move_to_scene(max_scene)
	if event.is_action_pressed("ui_navigation_toggle"): # 상단 네비게이터 토글
		toggle_navigator()

func previous_animation_stack():
	print_debug('이전 애니메이션 스택으로')

func next_animation_stack():
	print_debug('다음 애니메이션 스택으로')

func previous_scene():
	print_debug('이전 장면으로')

func next_scene():
	print_debug('다음 장면으로')

func move_to_scene(page_id:int):
	print_debug('이 장면으로:', page_id)

func toggle_navigator():
	is_navigator_open = !is_navigator_open
	print_debug('네비게이션 토글: ',is_navigator_open)
