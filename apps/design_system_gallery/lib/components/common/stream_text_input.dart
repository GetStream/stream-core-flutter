import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamTextInput,
  path: '[Components]/Common',
)
Widget buildStreamTextInputPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _value = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final hintText = context.knobs.string(
      label: 'Hint Text',
      initialValue: 'Enter text...',
    );

    final helperText = context.knobs.stringOrNull(
      label: 'Helper Text',
    );

    final helperState = context.knobs.object.dropdown<StreamHelperState>(
      label: 'Helper State',
      options: StreamHelperState.values,
      labelBuilder: (s) => s.name,
      description: 'Only visible when helper text is set.',
    );

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'When true, the field does not respond to interaction.',
    );

    final isReadOnly = context.knobs.boolean(
      label: 'Read Only',
      description: 'When true, the field shows text but cannot be edited.',
    );

    final showLeading = context.knobs.boolean(
      label: 'Show Leading Icon',
    );

    final showTrailing = context.knobs.boolean(
      label: 'Show Trailing Icon',
    );

    final maxLines = context.knobs.int.slider(
      label: 'Max Lines',
      initialValue: 1,
      min: 1,
      max: 5,
      description: 'Maximum number of visible lines. Set > 1 for multiline.',
    );

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.xl),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  spacing.lg,
                  spacing.lg,
                  spacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing.xxs,
                  children: [
                    Text(
                      'StreamTextInput',
                      style: textTheme.headingSm.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Use the knobs to configure the input and interact '
                      'with the live preview below.',
                      style: textTheme.captionDefault.copyWith(
                        color: colorScheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacing.sm,
                  children: [
                    StreamTextInput(
                      hintText: hintText,
                      helperText: helperText,
                      helperState: helperText != null ? helperState : null,
                      enabled: !isDisabled,
                      readOnly: isReadOnly,
                      maxLines: maxLines,
                      leading: showLeading ? Icon(context.streamIcons.search20) : null,
                      trailing: showTrailing ? Icon(context.streamIcons.xmark20) : null,
                      onChanged: (v) => setState(() => _value = v),
                    ),
                    if (_value.isNotEmpty)
                      Text(
                        'Value: "$_value"',
                        style: textTheme.metadataDefault.copyWith(
                          color: colorScheme.textTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamTextInput,
  path: '[Components]/Common',
)
Widget buildStreamTextInputShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _StatesSection(),
          _HelperStatesSection(),
          _VariationsSection(),
          _InteractiveSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// States Section
// =============================================================================

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return _Section(
      label: 'STATES',
      description: 'Core visual states of the text input.',
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              _StateDemo(
                label: 'Default',
                description: 'Empty field with hint text',
                child: StreamTextInput(
                  hintText: 'Enter text...',
                  onChanged: (_) {},
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'With Value',
                description: 'Field with pre-filled text',
                child: StreamTextInput(
                  initialValue: 'Hello world',
                  onChanged: (_) {},
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Read Only',
                description: 'Visible but not editable',
                child: StreamTextInput(
                  initialValue: 'Cannot modify this',
                  readOnly: true,
                  onChanged: (_) {},
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled',
                description: 'Non-interactive state',
                child: StreamTextInput(
                  initialValue: 'Cannot edit',
                  enabled: false,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: spacing.xs),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: colorScheme.textTertiary),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  'Tap any field above to see the focused border state',
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper States Section
// =============================================================================

class _HelperStatesSection extends StatelessWidget {
  const _HelperStatesSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return _Section(
      label: 'HELPER STATES',
      description:
          'Animated helper text with state-driven icon and color. '
          'The border color also changes to match the error state.',
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              Text(
                'Each state resolves a unique icon, text color, and '
                '(for error) border color from design tokens.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              Column(
                spacing: spacing.md,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HelperDemo(
                    label: 'info',
                    child: StreamTextInput(
                      initialValue: 'Some text',
                      helperText: 'This is an informational message',
                      helperState: StreamHelperState.info,
                      onChanged: (_) {},
                    ),
                  ),
                  _HelperDemo(
                    label: 'error',
                    child: StreamTextInput(
                      hintText: 'Required field',
                      helperText: 'This field is required',
                      helperState: StreamHelperState.error,
                      onChanged: (_) {},
                    ),
                  ),
                  _HelperDemo(
                    label: 'success',
                    child: StreamTextInput(
                      initialValue: 'valid-input',
                      helperText: 'Looks good!',
                      helperState: StreamHelperState.success,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HelperDemo extends StatelessWidget {
  const _HelperDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// Variations Section
// =============================================================================

class _VariationsSection extends StatelessWidget {
  const _VariationsSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'VARIATIONS',
      description: 'Leading and trailing widget slots for icons or actions.',
      children: [
        _ExampleCard(
          title: 'Search Field',
          description: 'Leading search icon for filter inputs',
          child: _LeadingIconDemo(),
        ),
        _ExampleCard(
          title: 'Clearable Field',
          description: 'Trailing clear button to reset content',
          child: _TrailingIconDemo(),
        ),
        _ExampleCard(
          title: 'Both Slots',
          description: 'Leading and trailing widgets together',
          child: _BothIconsDemo(),
        ),
        _ExampleCard(
          title: 'Multiline',
          description: 'Expandable text area for longer content',
          child: _MultilineDemo(),
        ),
      ],
    );
  }
}

class _LeadingIconDemo extends StatelessWidget {
  const _LeadingIconDemo();

  @override
  Widget build(BuildContext context) {
    return StreamTextInput(
      hintText: 'Search messages...',
      leading: Icon(context.streamIcons.search20),
      onChanged: (_) {},
    );
  }
}

class _TrailingIconDemo extends StatefulWidget {
  const _TrailingIconDemo();

  @override
  State<_TrailingIconDemo> createState() => _TrailingIconDemoState();
}

class _TrailingIconDemoState extends State<_TrailingIconDemo> {
  final _controller = TextEditingController(text: 'Clear me');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamTextInput(
      controller: _controller,
      trailing: GestureDetector(
        onTap: _controller.clear,
        child: Icon(context.streamIcons.xmark20),
      ),
    );
  }
}

class _BothIconsDemo extends StatelessWidget {
  const _BothIconsDemo();

  @override
  Widget build(BuildContext context) {
    return StreamTextInput(
      hintText: 'Enter a name...',
      leading: Icon(context.streamIcons.user20),
      trailing: Icon(context.streamIcons.checkmark20),
      onChanged: (_) {},
    );
  }
}

class _MultilineDemo extends StatelessWidget {
  const _MultilineDemo();

  @override
  Widget build(BuildContext context) {
    return StreamTextInput(
      hintText: 'Write a longer message...',
      maxLines: 4,
      minLines: 2,
      onChanged: (_) {},
    );
  }
}

// =============================================================================
// Interactive Section
// =============================================================================

class _InteractiveSection extends StatelessWidget {
  const _InteractiveSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'INTERACTIVE',
      description:
          'Type in the fields to see live state changes, '
          'helper text transitions, and validation feedback.',
      children: [
        _ExampleCard(
          title: 'Live Validation',
          description: 'Helper text animates in when validation triggers',
          child: _LiveValidationDemo(),
        ),
      ],
    );
  }
}

class _LiveValidationDemo extends StatefulWidget {
  const _LiveValidationDemo();

  @override
  State<_LiveValidationDemo> createState() => _LiveValidationDemoState();
}

class _LiveValidationDemoState extends State<_LiveValidationDemo> {
  var _value = '';

  (String?, StreamHelperState?) get _helper {
    if (_value.isEmpty) return (null, null);
    if (_value.length < 3) return ('Must be at least 3 characters', StreamHelperState.error);
    if (_value.length > 20) return ('Must be 20 characters or less', StreamHelperState.error);
    return ('Valid username', StreamHelperState.success);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final (helperText, helperState) = _helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        StreamTextInput(
          hintText: 'Choose a username',
          leading: Icon(context.streamIcons.user20),
          helperText: helperText,
          helperState: helperState,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]'))],
          onChanged: (v) => setState(() => _value = v),
        ),
        Text(
          '${_value.length}/20 characters',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      label: 'REAL-WORLD EXAMPLES',
      children: [
        _ExampleCard(
          title: 'Login Form',
          description: 'Email and password fields with submit validation.',
          child: _LoginFormExample(),
        ),
        _ExampleCard(
          title: 'Search Bar',
          description: 'Compact search input with clear action.',
          child: _SearchBarExample(),
        ),
      ],
    );
  }
}

class _LoginFormExample extends StatefulWidget {
  const _LoginFormExample();

  @override
  State<_LoginFormExample> createState() => _LoginFormExampleState();
}

class _LoginFormExampleState extends State<_LoginFormExample> {
  var _email = '';
  var _password = '';
  var _submitted = false;

  String? get _emailError {
    if (!_submitted) return null;
    if (_email.isEmpty) return 'Email is required';
    if (!_email.contains('@') || _email.endsWith('@')) return 'Enter a valid email';
    return null;
  }

  String? get _passwordError {
    if (!_submitted) return null;
    if (_password.isEmpty) return 'Password is required';
    if (_password.length < 6) return 'Must be at least 6 characters';
    return null;
  }

  StreamHelperState? _stateFor(String? error) {
    if (error != null) return StreamHelperState.error;
    if (_submitted) return StreamHelperState.success;
    return null;
  }

  String? _successText(String? error) {
    if (error != null) return error;
    if (_submitted) return 'Looks good';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    return Column(
      spacing: spacing.md,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamTextInput(
          hintText: 'Email address',
          initialValue: _email,
          keyboardType: TextInputType.emailAddress,
          leading: const Icon(Icons.email_outlined, size: 20),
          helperText: _successText(_emailError),
          helperState: _stateFor(_emailError),
          onChanged: (v) => setState(() => _email = v),
        ),
        StreamTextInput(
          hintText: 'Password',
          initialValue: _password,
          leading: Icon(context.streamIcons.lock20),
          helperText: _successText(_passwordError),
          helperState: _stateFor(_passwordError),
          onChanged: (v) => setState(() => _password = v),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: StreamButton(
            label: _submitted ? 'Submitted' : 'Sign In',
            onTap: () => setState(() => _submitted = true),
          ),
        ),
        if (_submitted && _emailError == null && _passwordError == null)
          Text(
            'Signed in successfully!',
            style: TextStyle(color: colorScheme.accentSuccess),
          ),
      ],
    );
  }
}

class _SearchBarExample extends StatefulWidget {
  const _SearchBarExample();

  @override
  State<_SearchBarExample> createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<_SearchBarExample> {
  final _controller = TextEditingController();
  var _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamTextInput(
      controller: _controller,
      hintText: 'Search conversations...',
      leading: Icon(context.streamIcons.search20),
      trailing: _hasText
          ? GestureDetector(
              onTap: _controller.clear,
              child: Icon(context.streamIcons.xmark20),
            )
          : null,
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    this.description,
    required this.children,
  });

  final String label;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.xxs,
          children: [
            _SectionLabel(label: label),
            if (description case final desc?)
              Text(
                desc,
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
          ],
        ),
        ...children,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: child,
    );
  }
}

class _StateDemo extends StatelessWidget {
  const _StateDemo({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
            Text(
              description,
              style: textTheme.metadataDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
