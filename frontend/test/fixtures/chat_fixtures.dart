const conversationResponseJson = {
  'id': '660e8400-e29b-41d4-a716-446655440001',
  'agent_type': 'academic',
  'persona_id': null,
  'title': '数学函数问题',
  'status': 'active',
  'message_count': 5,
  'last_message_at': '2024-06-01T10:30:00Z',
  'created_at': '2024-06-01T10:00:00Z',
};

const conversationListJson = [
  {
    'id': '660e8400-e29b-41d4-a716-446655440001',
    'agent_type': 'academic',
    'persona_id': null,
    'title': '数学函数问题',
    'status': 'active',
    'message_count': 5,
    'last_message_at': '2024-06-01T10:30:00Z',
    'created_at': '2024-06-01T10:00:00Z',
  },
  {
    'id': '660e8400-e29b-41d4-a716-446655440002',
    'agent_type': 'emotional',
    'persona_id': '770e8400-e29b-41d4-a716-446655440001',
    'title': null,
    'status': 'active',
    'message_count': 12,
    'last_message_at': '2024-06-01T09:00:00Z',
    'created_at': '2024-05-30T15:00:00Z',
  },
];

const messageListResponseJson = {
  'messages': [
    {
      'id': '880e8400-e29b-41d4-a716-446655440001',
      'role': 'user',
      'content_type': 'text',
      'content': '请帮我解一下这道函数题',
      'emotion_label': null,
      'intent_label': 'academic',
      'token_count': null,
      'created_at': '2024-06-01T10:00:00Z',
    },
    {
      'id': '880e8400-e29b-41d4-a716-446655440002',
      'role': 'assistant',
      'content_type': 'text',
      'content': '好的，我来帮你分析这道函数题。首先，让我们看看题目的条件...',
      'emotion_label': 'calm',
      'intent_label': 'academic',
      'token_count': 128,
      'created_at': '2024-06-01T10:00:05Z',
    },
  ],
  'total': 2,
  'page': 1,
  'size': 20,
};

const wsConnectedJson = {
  'type': 'connected',
  'data': {'user_id': '550e8400-e29b-41d4-a716-446655440000'},
};

const wsStreamStartJson = {
  'type': 'stream_start',
  'data': {},
};

const wsStreamChunkJson = {
  'type': 'stream_chunk',
  'data': {'content': '好的'},
};

const wsStreamEndJson = {
  'type': 'stream_end',
  'data': {
    'message_id': '990e8400-e29b-41d4-a716-446655440001',
    'emotion_label': 'calm',
    'intent_label': 'academic',
  },
};

const wsErrorJson = {
  'type': 'error',
  'data': {'message': '消息处理失败'},
};
