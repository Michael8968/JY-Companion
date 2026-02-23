"""Positive psychology intervention strategy library (≥50 strategies).

Based on CBT, mindfulness, and positive psychology principles.
"""

from dataclasses import dataclass

from app.models.emotion import EmotionLabel


@dataclass
class InterventionStrategy:
    id: str
    name: str
    category: str  # breathing / mindfulness / cognitive / behavioral / gratitude / social
    target_emotions: list[EmotionLabel]
    description: str
    instructions: str
    duration_minutes: int


STRATEGIES: list[InterventionStrategy] = [
    # === Breathing Exercises (呼吸练习) ===
    InterventionStrategy("br01", "4-7-8 呼吸法", "breathing", [EmotionLabel.ANXIOUS, EmotionLabel.FEARFUL],
        "经典放松呼吸技巧", "吸气4秒 → 屏气7秒 → 呼气8秒，重复4轮", 3),
    InterventionStrategy("br02", "腹式呼吸", "breathing", [EmotionLabel.ANXIOUS, EmotionLabel.ANGRY],
        "深层腹式呼吸缓解紧张", "双手放腹部，吸气时腹部鼓起，呼气时收缩，每次5-10分钟", 5),
    InterventionStrategy("br03", "方块呼吸法", "breathing", [EmotionLabel.ANXIOUS],
        "军事级压力管理技巧", "吸气4秒 → 屏气4秒 → 呼气4秒 → 屏气4秒，重复5轮", 3),
    InterventionStrategy("br04", "数息冥想", "breathing", [EmotionLabel.ANXIOUS, EmotionLabel.DEPRESSED],
        "数息聚焦注意力", "闭眼，每次呼吸默数1-10，走神时重新从1开始", 5),
    InterventionStrategy("br05", "蝴蝶拥抱", "breathing", [EmotionLabel.SAD, EmotionLabel.FEARFUL],
        "自我安抚技巧", "双臂交叉放胸前，左右交替轻拍肩膀，配合深呼吸", 3),

    # === Mindfulness (正念练习) ===
    InterventionStrategy("mn01", "身体扫描", "mindfulness", [EmotionLabel.ANXIOUS, EmotionLabel.DEPRESSED],
        "从头到脚的觉察练习", "闭眼，从头顶开始依次关注身体各部位的感觉，不评判，只觉察", 10),
    InterventionStrategy("mn02", "五感觉察", "mindfulness", [EmotionLabel.ANXIOUS, EmotionLabel.FEARFUL],
        "5-4-3-2-1接地技巧", "观察5个看到的→4个触到的→3个听到的→2个闻到的→1个尝到的", 5),
    InterventionStrategy("mn03", "正念行走", "mindfulness", [EmotionLabel.DEPRESSED, EmotionLabel.SAD],
        "行走中的觉察", "慢慢走路，注意脚底接触地面的感觉，感受每一步", 10),
    InterventionStrategy("mn04", "思绪云朵", "mindfulness", [EmotionLabel.ANXIOUS],
        "与想法保持距离", "把每个想法想象成天空中飘过的云朵，不抓住，让它自然飘走", 5),
    InterventionStrategy("mn05", "正念饮水", "mindfulness", [EmotionLabel.ANGRY],
        "日常正念练习", "慢慢喝一杯水，感受水的温度、味道、经过喉咙的感觉", 3),
    InterventionStrategy("mn06", "慈悲冥想", "mindfulness", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "向自己发送善意", "默念：愿我平安、愿我快乐、愿我健康、愿我自在", 10),
    InterventionStrategy("mn07", "进食冥想", "mindfulness", [EmotionLabel.ANXIOUS],
        "用餐时的正念练习", "细细品尝每一口食物的味道、质地和温度", 10),

    # === Cognitive (认知调节) ===
    InterventionStrategy("cg01", "认知重构", "cognitive", [EmotionLabel.DEPRESSED, EmotionLabel.ANXIOUS],
        "CBT核心技术", "写下消极想法→寻找证据支持和反对→形成更平衡的想法", 10),
    InterventionStrategy("cg02", "灾难化解构", "cognitive", [EmotionLabel.ANXIOUS, EmotionLabel.FEARFUL],
        "打破灾难化思维", "问自己：最坏结果是什么？最好结果是什么？最可能的结果是什么？", 5),
    InterventionStrategy("cg03", "三件好事", "cognitive", [EmotionLabel.DEPRESSED, EmotionLabel.SAD],
        "积极心理学经典练习", "每晚写下今天三件好事和它们发生的原因", 5),
    InterventionStrategy("cg04", "成长型思维", "cognitive", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "将失败重新定义为学习", "把'我失败了'替换为'我正在学习中'，列出从中学到了什么", 5),
    InterventionStrategy("cg05", "自我对话改善", "cognitive", [EmotionLabel.DEPRESSED],
        "用对朋友的方式对待自己", "想象好朋友遇到同样的事，你会怎么安慰？用同样的话对自己说", 5),
    InterventionStrategy("cg06", "积极回忆", "cognitive", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "唤醒美好记忆", "回忆一个让你微笑的美好时刻，尽量回想细节和当时的感受", 5),
    InterventionStrategy("cg07", "优势发现", "cognitive", [EmotionLabel.DEPRESSED],
        "识别个人优势", "列出自己的5个优点或过去成功克服困难的经历", 5),
    InterventionStrategy("cg08", "感恩信", "cognitive", [EmotionLabel.SAD],
        "向感恩的人写封信", "给一个帮助过你的人写一封感谢信（不必寄出）", 15),

    # === Behavioral (行为激活) ===
    InterventionStrategy("bh01", "微小行动", "behavioral", [EmotionLabel.DEPRESSED],
        "从最小的行动开始", "选择一个极其简单的任务去完成，如整理桌面、洗一个杯子", 5),
    InterventionStrategy("bh02", "运动放松", "behavioral", [EmotionLabel.ANGRY, EmotionLabel.ANXIOUS],
        "通过身体活动释放情绪", "做10个深蹲或原地跑步2分钟，让身体释放紧张感", 5),
    InterventionStrategy("bh03", "创意表达", "behavioral", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "通过创造表达情绪", "画一幅画、写一首短诗或哼一首歌来表达现在的感受", 15),
    InterventionStrategy("bh04", "愉悦活动清单", "behavioral", [EmotionLabel.DEPRESSED],
        "做让自己开心的小事", "列出5件简单的让你开心的事，选一件现在就做", 10),
    InterventionStrategy("bh05", "渐进式肌肉放松", "behavioral", [EmotionLabel.ANXIOUS],
        "系统性肌肉放松", "从脚趾开始，依次绷紧-放松每个肌肉群，每次保持5秒", 15),
    InterventionStrategy("bh06", "音乐疗愈", "behavioral", [EmotionLabel.SAD, EmotionLabel.ANXIOUS],
        "用音乐调节情绪", "选一首让你感到平静或愉快的歌曲，闭眼专注聆听", 5),
    InterventionStrategy("bh07", "自然接触", "behavioral", [EmotionLabel.DEPRESSED, EmotionLabel.ANXIOUS],
        "与自然连接", "到窗边看看天空、树木，或者浇一次花，感受自然的力量", 5),
    InterventionStrategy("bh08", "整理环境", "behavioral", [EmotionLabel.DEPRESSED],
        "外部秩序带来内心秩序", "花10分钟整理一下桌面或书包，一个小角落就好", 10),

    # === Gratitude (感恩练习) ===
    InterventionStrategy("gr01", "感恩日记", "gratitude", [EmotionLabel.DEPRESSED, EmotionLabel.SAD],
        "每日感恩记录", "写下今天你感恩的三件事，无论多小", 5),
    InterventionStrategy("gr02", "感恩漫步", "gratitude", [EmotionLabel.SAD],
        "在散步中发现美好", "散步时注意身边值得感恩的事物，默默说声谢谢", 15),
    InterventionStrategy("gr03", "感恩人物", "gratitude", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "感恩生命中的人", "想一个对你很重要的人，回忆他们为你做过的事", 5),
    InterventionStrategy("gr04", "逆境感恩", "gratitude", [EmotionLabel.DEPRESSED],
        "在困难中发现礼物", "回想一个困难经历，找出其中让你成长的部分", 10),

    # === Social (社交连接) ===
    InterventionStrategy("sc01", "善意传递", "social", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "帮助他人改善自己心情", "做一件小善事：帮同学一个忙、给朋友发条鼓励的消息", 5),
    InterventionStrategy("sc02", "倾诉练习", "social", [EmotionLabel.ANXIOUS, EmotionLabel.SAD],
        "向信任的人表达感受", "找一个信任的人（家人、朋友、老师）聊聊你的感受", 15),
    InterventionStrategy("sc03", "赞美他人", "social", [EmotionLabel.SAD],
        "发现他人的优点", "今天向一个人真诚地说出你欣赏他的地方", 3),
    InterventionStrategy("sc04", "回忆美好时光", "social", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "与朋友共享回忆", "和朋友一起回忆一段有趣或温暖的共同经历", 10),

    # === Study-Specific (学业相关) ===
    InterventionStrategy("st01", "番茄工作法", "behavioral", [EmotionLabel.ANXIOUS],
        "分段学习减轻压力", "学习25分钟→休息5分钟→重复，每4轮休息15分钟", 30),
    InterventionStrategy("st02", "考前放松", "breathing", [EmotionLabel.ANXIOUS, EmotionLabel.FEARFUL],
        "考试前的快速放松", "考前做3次4-7-8呼吸，然后对自己说'我已经准备好了'", 3),
    InterventionStrategy("st03", "成绩归因练习", "cognitive", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "正确归因考试成绩", "分析成绩时关注可控因素（努力、方法）而非不可控因素（天赋、运气）", 10),
    InterventionStrategy("st04", "学习成就清单", "cognitive", [EmotionLabel.DEPRESSED],
        "回顾学习进步", "列出最近一个月你在学习上取得的3个进步，无论多小", 5),
    InterventionStrategy("st05", "同伴学习", "social", [EmotionLabel.DEPRESSED, EmotionLabel.ANXIOUS],
        "合作学习减轻孤独感", "找一个同学一起学习或讨论问题", 30),
    InterventionStrategy("st06", "劳逸结合", "behavioral", [EmotionLabel.ANXIOUS],
        "在学习间隙放松", "每学习45分钟，站起来做眼保健操和简单伸展", 5),

    # === Self-Care (自我关爱) ===
    InterventionStrategy("sf01", "自我拥抱", "mindfulness", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "给自己一个温暖的拥抱", "双手环抱自己，轻轻拍打后背，对自己说'辛苦了'", 3),
    InterventionStrategy("sf02", "温暖饮品", "behavioral", [EmotionLabel.SAD, EmotionLabel.ANXIOUS],
        "用一杯热饮安抚自己", "泡一杯热茶或热牛奶，双手捧着，感受温度传递的安慰", 5),
    InterventionStrategy("sf03", "涂鸦释放", "behavioral", [EmotionLabel.ANGRY, EmotionLabel.ANXIOUS],
        "用随意涂鸦释放情绪", "拿一张纸和笔，随心涂画，不要求好看，只关注手的动作", 10),
    InterventionStrategy("sf04", "安全角落", "behavioral", [EmotionLabel.FEARFUL, EmotionLabel.ANXIOUS],
        "在脑海中建立安全空间", "闭眼想象一个让你感到安全的地方，注意那里的颜色、气味和声音", 5),
    InterventionStrategy("sf05", "情绪日记", "cognitive", [EmotionLabel.ANXIOUS, EmotionLabel.DEPRESSED],
        "用文字梳理情绪", "写下现在的感受，不需要逻辑和完整句子，只是把情绪倒出来", 10),
    InterventionStrategy("sf06", "睡前放松", "breathing", [EmotionLabel.ANXIOUS],
        "帮助入睡的放松技巧", "躺下后做10次缓慢的深呼吸，每次呼气时想象身体变重、下沉", 5),
    InterventionStrategy("sf07", "身体感恩", "gratitude", [EmotionLabel.DEPRESSED],
        "感恩自己的身体", "感谢双手帮你写字、感谢双脚带你走路，逐一感谢身体的每个部分", 5),
    InterventionStrategy("sf08", "微笑练习", "behavioral", [EmotionLabel.SAD, EmotionLabel.DEPRESSED],
        "用微笑改变情绪", "对着镜子微笑30秒，即使不开心也试试，感受面部肌肉的变化", 3),
]

# Verify ≥50 strategies
assert len(STRATEGIES) >= 50, f"Strategy library needs ≥50 entries, got {len(STRATEGIES)}"

# Index by category and emotion
_BY_EMOTION: dict[EmotionLabel, list[InterventionStrategy]] = {}
for _s in STRATEGIES:
    for _e in _s.target_emotions:
        _BY_EMOTION.setdefault(_e, []).append(_s)


def get_strategies_for_emotion(
    emotion: EmotionLabel, *, max_results: int = 5
) -> list[InterventionStrategy]:
    """Get intervention strategies suitable for a given emotion."""
    candidates = _BY_EMOTION.get(emotion, [])
    return candidates[:max_results]


def get_strategies_by_category(category: str) -> list[InterventionStrategy]:
    """Get all strategies in a category."""
    return [s for s in STRATEGIES if s.category == category]
