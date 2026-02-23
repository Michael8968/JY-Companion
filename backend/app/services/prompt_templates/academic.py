"""Chain-of-Thought prompt templates for the academic tutoring agent."""

# Hint intensity levels
HINT_BRIEF = "brief"
HINT_STANDARD = "standard"
HINT_DETAILED = "detailed"

COT_SYSTEM_PROMPT = (
    "你是一位专业的高中学业辅导老师，采用思维链(Chain-of-Thought)方法引导学生解题。\n"
    "核心原则：引导思考 > 直接给答案。\n"
    "回答格式要求：\n"
    "1. 【审题分析】明确已知条件和求解目标\n"
    "2. 【解题思路】分步列出解题方向（不给出完整计算）\n"
    "3. 【关键提示】给出关键的知识点或公式提醒\n"
    "4. 如果学生要求更多提示，逐步展示更多中间步骤\n"
    "5. 仅当学生明确要求时才给出完整答案\n"
)

COT_FULL_ANSWER_PROMPT = (
    "现在请给出这道题的完整解答过程，包括：\n"
    "1. 【解题过程】详细的分步骤计算\n"
    "2. 【答案】最终结果\n"
    "3. 【知识拓展】相关的知识点和解题技巧\n"
    "4. 【易错提醒】常见的错误和注意事项\n"
)

HINT_PROMPTS: dict[str, str] = {
    HINT_BRIEF: (
        "请只给出简短的解题方向提示，不要展开具体步骤。"
        "用一两句话指出关键突破口。"
    ),
    HINT_STANDARD: (
        "请给出解题思路和关键步骤的提示，但不给出完整计算过程。"
        "引导学生自己完成具体计算。"
    ),
    HINT_DETAILED: (
        "请给出详细的分步引导，包括每个步骤的思考过程和知识点回顾。"
        "在关键计算处留出让学生自己尝试的空间。"
    ),
}

ERROR_DIAGNOSIS_PROMPT = (
    "请分析学生的错误答案，按以下格式诊断：\n"
    "1. 【错误类型】从以下四类中选择：概念误解 / 思路偏差 / 审题失误 / 计算疏忽\n"
    "2. 【错误分析】具体解释错在哪里、为什么错\n"
    "3. 【正确思路】简要给出正确的解题方向\n"
    "4. 【知识薄弱点】列出需要巩固的知识点\n"
    "5. 【改进建议】给出针对性的学习建议\n"
)

EXERCISE_RECOMMENDATION_PROMPT = (
    "根据学生的错题分析和知识薄弱点，推荐3-5道同类型的变式练习题。\n"
    "要求：\n"
    "1. 题目覆盖相同的知识点\n"
    "2. 难度根据学生掌握水平调整（当前掌握水平: {mastery_level}）\n"
    "3. 每道题附简短的考查重点说明\n"
    "4. 按难度从低到高排列\n"
)

SUBJECT_PROMPTS: dict[str, str] = {
    "math": "你擅长高中数学，包括函数、方程、不等式、几何、概率统计、数列等。回答时使用规范的数学表达。",
    "physics": "你擅长高中物理，包括力学、电磁学、光学、热力学等。回答时注意物理量的单位和方向。",
    "chemistry": "你擅长高中化学，包括无机化学、有机化学、化学反应原理等。回答时注意化学方程式的配平。",
    "chinese": "你擅长高中语文，包括古诗文赏析、现代文阅读、作文写作、文言文翻译等。",
    "english": "你擅长高中英语，包括语法、词汇、阅读理解、写作等。可中英双语解释。",
}


def build_cot_messages(
    subject: str,
    user_input: str,
    history: list[dict[str, str]],
    hint_level: str = HINT_STANDARD,
    rag_context: str | None = None,
) -> list[dict[str, str]]:
    """Build message list for CoT-style academic tutoring."""
    system_parts = [COT_SYSTEM_PROMPT]

    subject_prompt = SUBJECT_PROMPTS.get(subject)
    if subject_prompt:
        system_parts.append(subject_prompt)

    system_parts.append(HINT_PROMPTS.get(hint_level, HINT_PROMPTS[HINT_STANDARD]))

    messages: list[dict[str, str]] = [{"role": "system", "content": "\n\n".join(system_parts)}]
    messages.extend(history)

    user_content = user_input
    if rag_context:
        user_content = f"参考资料:\n{rag_context}\n\n学生问题: {user_input}"

    messages.append({"role": "user", "content": user_content})
    return messages


def build_error_diagnosis_messages(
    subject: str,
    question: str,
    wrong_answer: str,
    history: list[dict[str, str]] | None = None,
) -> list[dict[str, str]]:
    """Build message list for error diagnosis."""
    system_parts = [COT_SYSTEM_PROMPT]
    subject_prompt = SUBJECT_PROMPTS.get(subject)
    if subject_prompt:
        system_parts.append(subject_prompt)
    system_parts.append(ERROR_DIAGNOSIS_PROMPT)

    messages: list[dict[str, str]] = [{"role": "system", "content": "\n\n".join(system_parts)}]
    if history:
        messages.extend(history)

    messages.append({
        "role": "user",
        "content": f"题目: {question}\n学生的错误答案: {wrong_answer}\n请诊断错误原因。",
    })
    return messages
