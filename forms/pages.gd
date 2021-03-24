extends Control
class_name PageScene

# 현재 애니메이션 진행 커서
var current_animation_id:=0
# 이 씬에는 애니메이션 스택이 최대 몇개까지 있습니다.
export var max_animation_stack:int

func _init():
	hide() # 보통 캐시로 로드되기 때문에 시작부터 숨김

func _ready():
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
		print_debug('이전 애니메이션 스택으로: ',current_animation_id)

func next_animation_stack():
	var precaled:=current_animation_id + 1
	if precaled > max_animation_stack:
		Root.next_scene()
	else:
		current_animation_id = precaled
		print_debug('다음 애니메이션 스택으로: ',current_animation_id)
