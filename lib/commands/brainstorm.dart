import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:domine/checker.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:tint/tint.dart';

class BrainstormCommand extends Command {
  final List<CheckedDomain> _searches = [];

  @override
  String get description => 'Choose a domain with AI';

  @override
  String get name => 'brainstorm';

  @override
  bool get hidden => true;

  @override
  List<String> get aliases => ['b'];

  BrainstormCommand() {
    argParser.addOption(
      'openai-key',
      abbr: 'k',
      help: 'OpenAI API key',
    );
    argParser.addOption(
      'model',
      abbr: 'm',
      help: 'GPT model',
      defaultsTo: 'gpt-3.5-turbo',
    );
    argParser.addOption(
      'target',
      abbr: 't',
      help: 'How many available domains the model should find?',
      defaultsTo: '10',
    );
  }

  @override
  void run() async {
    final results = argResults!;
    OpenAI.apiKey = Platform.environment['OPENAI_KEY'] ?? results['openai-key'];

    await _brainstorm(
      results.rest.join(' '),
      model: results['model'],
      target: int.parse(results['target']),
    );
  }

  Future<void> _brainstorm(String prompt,
      {required String model, required int target}) async {
    domainTable(_searches);

    if (_searches.where((e) => e.available).length >= target) return;

    final spinner =
        Spinner.type('Synthesizing domains with GPT...', SpinnerType.dots)
          ..start();

    final response = await OpenAI.instance.chat.create(
      model: model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            'You are a creative AI whose task is to find domains for your clients.',
            'Example domain ideas: superbakery.com, nudes4sale.co, etc.',
            'Your domain searching task is: $prompt'
          ].join('\n'),
        ),
        if (_searches.isNotEmpty)
          OpenAIChatCompletionChoiceMessageModel(
            functionName: 'checkDomains',
            role: OpenAIChatMessageRole.function,
            content: 'Already been checked: ${_searches.join(', ')}',
          )
      ],
      functionCall: FunctionCall.forFunction('checkDomains'),
      functions: [
        OpenAIFunctionModel.withParameters(
          name: 'checkDomains',
          parameters: [
            OpenAIFunctionProperty.array(
              name: 'domains',
              items: OpenAIFunctionProperty.string(
                name: 'domain',
                description: 'Full domain name (e.g. google.com, nesper.co)',
              ),
            )
          ],
        ),
      ],
    );
    final message = response.choices.first.message;
    final candidates =
        List<String>.from(message.functionCall!.arguments!['domains'] ?? [])
            .where((e) =>
                e.contains('.') &&
                !e.endsWith('.') &&
                !_searches.any((v) => v.toString() == e));

    if (candidates.isNotEmpty) {
      spinner.updateMessage('Checking ${candidates.length} new domains...');
      final checks = await batchCheck(candidates);
      _searches.addAll(checks);
    }

    spinner
      ..updateMessage(
          '${_searches.where((e) => e.available).length} available domains out of ${_searches.length} checked'
              .dim()
              .underline())
      ..stop();

    await _brainstorm(prompt, model: model, target: target);
  }
}
