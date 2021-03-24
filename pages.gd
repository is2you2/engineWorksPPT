extends Control
class_name PageScene

# 현재 애니메이션 진행 커서
var current_animation_id:=0
# 이 씬에는 애니메이션 스택이 최대 몇개까지 있습니다.
export var max_animation_stack:int
# 네비게이션에서 보여지는 짧은 설명구
export var page_desc:String

func _init():
	hide() # 보통 캐시로 로드되기 때문에 시작부터 숨김

func _ready(): # 활성시 인풋도 열릴 예정
	set_process_input(false)

func _input(event):
	# 씬 내 이전 애니메이션
	if event.is_action_pressed("ppt_stack_prev"):
		previous_animation_stack()
	# 씬 내 다음 애니메이션
	if event.is_action_pressed("ppt_stack_next"):
		next_animation_stack()

func previous_animation_stack():
	var precaled:=current_animation_id - 1
	if precaled < 0:
		Root.previous_scene()
	else:
		current_animation_id = precaled
		previous_animation_stack_action()
		print_debug('이전 애니메이션 스택으로: ',current_animation_id)

func next_animation_stack():
	var precaled:=current_animation_id + 1
	if precaled > max_animation_stack:
		Root.next_scene()
	else:
		current_animation_id = precaled
		next_animation_stack_action()
		print_debug('다음 애니메이션 스택으로: ',current_animation_id)

var force_remove:=false
func _exit_tree():
	Root.swap_scenes(self)

# Override belows
# 사용자가 함수로 구분해줘야함
func previous_animation_stack_action():
	match(current_animation_id):
		_:
			printerr('previous_animation_stack_action 함수가 구성되지 않음 (Scene: %s / anim: %d)'%[name,current_animation_id])

func next_animation_stack_action():
	match(current_animation_id):
		_:
			printerr('next_animation_stack_action 함수가 구성되지 않음 (Scene: %s / anim: %d)'%[name,current_animation_id])

# 씬을 나갈 때 액션
func _user_command_exit():
	if force_remove:
		queue_free()
		return
