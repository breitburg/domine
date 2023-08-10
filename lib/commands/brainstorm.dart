import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:domine/checker.dart';
import 'package:domine/misc.dart';
import 'package:domine/models.dart';
import 'package:domine/spinner.dart';
import 'package:tint/tint.dart';

class BrainstormCommand extends Command {
  final List<CheckedDomain> _searches = [];

  @override
  String get description => 'Choose a domain with AI';

  @override
  String get name => 'brainstorm';

  @override
  String get invocation => 'brainstorm <prompt>';

  @override
  List<String> get aliases => ['b'];

  BrainstormCommand() {
    argParser.addOption(
      'openai-key',
      help: 'Define the OpenAI API key.',
    );
    argParser.addOption(
      'model',
      help: 'Specify the GPT model.',
      defaultsTo: 'gpt-3.5-turbo',
    );
    argParser.addOption(
      'limit',
      abbr: 'l',
      help:
          'Specify the maximum number of available domains the model should find.',
      valueHelp: 'number',
      defaultsTo: '10',
    );
    argParser.addSeparator('Model Settings');
    argParser.addOption(
      'temperature',
      help: 'Specify the model temperature.',
      valueHelp: 'from 0.0 to 2.0',
      defaultsTo: '1.0',
    );
    argParser.addOption(
      'frequency-penalty',
      help:
          'Specify the model frequency penalty to decrease the likelihood of the model repeating the same line verbatim.',
      valueHelp: 'from 0.0 to 2.0',
      defaultsTo: '0.0',
    );
  }

  @override
  void run() async {
    final results = argResults!;
    OpenAI.apiKey = Platform.environment['OPENAI_KEY'] ?? results['openai-key'];

    await _brainstorm(
      results.rest.join(' '),
      model: results['model'],
      limit: int.parse(results['limit']),
      temperature: double.parse(results['temperature']),
      frequencyPenalty: double.parse(results['frequency-penalty']),
    );
  }

  Future<void> _brainstorm(
    String prompt, {
    required String model,
    required int limit,
    required double temperature,
    required double frequencyPenalty,
  }) async {
    domainTable(_searches);

    if (_searches.where((e) => e.available).length >= limit) return;

    final spinner = Spinner('Synthesizing with GPT...')..start();

    final response = await OpenAI.instance.chat.create(
      model: model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            'You are a creative AI whose task is to find domains for your clients.',
            'Example domain ideas: superbakery.com, nudes4sale.app, etc.',
            'Your domain searching task is: $prompt'
          ].join('\n'),
        ),
        if (_searches.isNotEmpty)
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.function,
            functionName: 'checkDomains',
            content: 'Already been checked: ${_searches.join(', ')}',
          )
      ],
      frequencyPenalty: frequencyPenalty,
      temperature: temperature,
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
      spinner.text = 'Checking ${candidates.length} new domains...';
      await batchCheck(candidates).forEach(_searches.add);
    }

    spinner.stop();

    stdout.writeln(
      '${_searches.where((e) => e.available).length} available domains out of ${_searches.length} checked'
          .dim()
          .underline(),
    );

    await _brainstorm(
      prompt,
      model: model,
      limit: limit,
      temperature: temperature,
      frequencyPenalty: frequencyPenalty,
    );
  }
}
