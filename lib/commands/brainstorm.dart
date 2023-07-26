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
  }

  @override
  void run() async {
    final results = argResults!;
    OpenAI.apiKey = Platform.environment['OPENAI_KEY'] ?? results['openai-key'];

    await _brainstorm(results.rest.join(' '), model: results['model']);
  }

  Future<void> _brainstorm(String prompt, {required String model}) async {
    domainTable(_searches);

    final spinner =
        Spinner.type('Synthesizing domains with GPT...', SpinnerType.dots)
          ..start();

    final response = await OpenAI.instance.chat.create(
      model: model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            'You are a creative AI that task is to find domains for your client.',
            'Example queries: superbakery.com, nudes4sale.co',
            'Domain search prompt: $prompt'
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
              name: 'queries',
              description: 'Must be at least 10 queries',
              items: OpenAIFunctionProperty.string(
                name: 'domain',
                description: 'Name and a TLD (example: google.com, nesper.co)',
              ),
            )
          ],
        ),
      ],
    );
    final message = response.choices.first.message;
    final queries =
        List<String>.from(message.functionCall!.arguments!['queries'].where(
      (e) =>
          e.contains('.') &&
          !e.endsWith('.') &&
          !_searches.any((v) => v.toString() == e),
    ));

    if (queries.isNotEmpty) {
      spinner.updateMessage('Checking ${queries.length} new domains...');
      final checks = await batchCheck(queries);
      _searches.addAll(checks);
    }

    spinner
      ..updateMessage('Currently, ${_searches.length} domains have been checked'
          .dim()
          .underline())
      ..stop();

    await _brainstorm(prompt, model: model);
  }
}
