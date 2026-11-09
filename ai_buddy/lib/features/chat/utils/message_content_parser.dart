/// Splits an assistant message into prose and fenced code blocks, so code
/// gets its own widget (language label, copy button, horizontal scroll)
/// while everything else is rendered as markdown.
///
/// Works on partial text while a reply streams in: an opening fence without
/// its closing fence yields an incomplete [CodeSegment].
sealed class ContentSegment {
  const ContentSegment();
}

/// Markdown prose (paragraphs, lists, tables, quotes, inline code).
final class MarkdownSegment extends ContentSegment {
  const MarkdownSegment(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is MarkdownSegment && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'MarkdownSegment($text)';
}

/// A fenced code block.
final class CodeSegment extends ContentSegment {
  const CodeSegment({required this.code, this.language, this.isComplete = true});

  final String code;

  /// From the fence info string, e.g. ```dart → "dart". Null if absent.
  final String? language;

  /// False while the closing fence hasn't streamed in yet.
  final bool isComplete;

  @override
  bool operator ==(Object other) =>
      other is CodeSegment &&
      other.code == code &&
      other.language == language &&
      other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(code, language, isComplete);

  @override
  String toString() => 'CodeSegment($language, complete: $isComplete, $code)';
}

final RegExp _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})[ \t]*([^\s`]*)');
final RegExp _edgeNewlines = RegExp(r'^\n+|\n+$');

List<ContentSegment> parseMessageContent(String content) {
  final segments = <ContentSegment>[];
  final prose = StringBuffer();
  StringBuffer? code;
  String? language;
  var fenceChar = '`';
  var fenceLength = 3;

  void flushProse() {
    final text = prose.toString().replaceAll(_edgeNewlines, '');
    if (text.trim().isNotEmpty) segments.add(MarkdownSegment(text));
    prose.clear();
  }

  String codeText(StringBuffer buffer) {
    final text = buffer.toString();
    return text.endsWith('\n') ? text.substring(0, text.length - 1) : text;
  }

  for (final line in content.split('\n')) {
    final currentCode = code;
    if (currentCode == null) {
      final match = _openingFence.firstMatch(line);
      if (match != null) {
        flushProse();
        final fence = match.group(1)!;
        fenceChar = fence[0];
        fenceLength = fence.length;
        final info = match.group(2)!;
        language = info.isEmpty ? null : info.toLowerCase();
        code = StringBuffer();
      } else {
        prose.writeln(line);
      }
      continue;
    }

    final trimmed = line.trim();
    final isClosingFence = trimmed.length >= fenceLength &&
        trimmed.split('').every((char) => char == fenceChar);
    if (isClosingFence) {
      segments.add(CodeSegment(code: codeText(currentCode), language: language));
      code = null;
      language = null;
    } else {
      currentCode.writeln(line);
    }
  }

  final unclosed = code;
  if (unclosed != null) {
    segments.add(
      CodeSegment(code: codeText(unclosed), language: language, isComplete: false),
    );
  } else {
    flushProse();
  }
  return segments;
}
