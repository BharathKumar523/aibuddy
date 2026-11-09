import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/features/chat/utils/message_content_parser.dart';

void main() {
  test('plain markdown is one segment', () {
    expect(
      parseMessageContent('Hello **world**\n\n- a\n- b'),
      const [MarkdownSegment('Hello **world**\n\n- a\n- b')],
    );
  });

  test('splits prose and a fenced code block with its language', () {
    const content = 'Intro text\n\n```dart\nvoid main() {}\n```\n\nOutro';

    expect(parseMessageContent(content), const [
      MarkdownSegment('Intro text'),
      CodeSegment(code: 'void main() {}', language: 'dart'),
      MarkdownSegment('Outro'),
    ]);
  });

  test('keeps code indentation and blank lines inside the block', () {
    const content = '```\nif (a) {\n\n  b();\n}\n```';

    expect(parseMessageContent(content), const [
      CodeSegment(code: 'if (a) {\n\n  b();\n}'),
    ]);
  });

  test('handles several code blocks and tilde fences', () {
    const content = '```js\na()\n```\ntext\n~~~python\nprint(1)\n~~~';

    expect(parseMessageContent(content), const [
      CodeSegment(code: 'a()', language: 'js'),
      MarkdownSegment('text'),
      CodeSegment(code: 'print(1)', language: 'python'),
    ]);
  });

  test('an unclosed fence (still streaming) is an incomplete code block', () {
    const content = 'Here you go:\n```dart\nfinal x = 1;\nfinal y';

    expect(parseMessageContent(content), const [
      MarkdownSegment('Here you go:'),
      CodeSegment(code: 'final x = 1;\nfinal y', language: 'dart', isComplete: false),
    ]);
  });

  test('a shorter or different fence does not close the block', () {
    const content = '````md\n```dart\ninner\n```\n````';

    expect(parseMessageContent(content), const [
      CodeSegment(code: '```dart\ninner\n```', language: 'md'),
    ]);
  });

  test('empty and whitespace-only content produce no segments', () {
    expect(parseMessageContent(''), isEmpty);
    expect(parseMessageContent('  \n\n '), isEmpty);
  });
}
