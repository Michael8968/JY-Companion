import 'package:flutter_test/flutter_test.dart';

import 'package:jy_companion/features/avatar/presentation/widgets/emotion_animator.dart';

void main() {
  group('EmotionAnimator', () {
    group('emotionToValue', () {
      test('returns known emotion values', () {
        expect(EmotionAnimator.emotionToValue('happy'), 0.85);
        expect(EmotionAnimator.emotionToValue('sad'), 0.15);
        expect(EmotionAnimator.emotionToValue('neutral'), 0.5);
        expect(EmotionAnimator.emotionToValue('excited'), 0.9);
        expect(EmotionAnimator.emotionToValue('calm'), 0.6);
        expect(EmotionAnimator.emotionToValue('angry'), 0.2);
        expect(EmotionAnimator.emotionToValue('anxious'), 0.25);
      });

      test('is case insensitive', () {
        expect(EmotionAnimator.emotionToValue('HAPPY'), 0.85);
        expect(EmotionAnimator.emotionToValue('Happy'), 0.85);
      });

      test('trims whitespace', () {
        expect(EmotionAnimator.emotionToValue('  happy  '), 0.85);
      });

      test('returns 0.5 for unknown emotion', () {
        expect(EmotionAnimator.emotionToValue('unknown'), 0.5);
        expect(EmotionAnimator.emotionToValue(''), 0.5);
      });

      test('emotionToValueMap has expected entries', () {
        expect(EmotionAnimator.emotionToValueMap['joy'], 0.9);
        expect(EmotionAnimator.emotionToValueMap['grateful'], 0.75);
        expect(EmotionAnimator.emotionToValueMap['tired'], 0.35);
        expect(EmotionAnimator.emotionToValueMap['confused'], 0.4);
      });
    });
  });
}
