// coverage:ignore-file

import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../logger.dart';

/// The stage of a request a record came from.
enum InterceptStep {
  /// A request on its way out.
  request,

  /// A response that came back.
  response,

  /// A request that failed.
  error,
}

/// Takes one line of the log, in place of the logger.
typedef LogPrint = void Function(InterceptStep step, Object object);

/// An interceptor that reports each request and the response it gets.
///
/// Records go out under `SC:Http`, at [StreamLogPriority.debug], or [StreamLogPriority.warning]
/// for a request that failed. Nothing is written, or even formatted, until an app installs a
/// [StreamLogHandler].
///
/// [requestHeader] puts the `Authorization` header in the record along with the rest, so consider
/// what reads these before turning it on.
class LoggingInterceptor extends Interceptor {
  /// Creates a new [LoggingInterceptor].
  LoggingInterceptor({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = true,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 120,
    this.compact = true,
    this.logPrint,
    String tag = 'SC:Http',
  }) : _logger = StreamLogger(tag);

  final StreamLogger _logger;

  /// Whether to report the request line.
  final bool request;

  /// Whether to report the request's headers, query parameters and extras.
  final bool requestHeader;

  /// Whether to report the request body.
  final bool requestBody;

  /// Whether to report the response body.
  final bool responseBody;

  /// Whether to report the response headers.
  final bool responseHeader;

  /// Whether to report a request that failed.
  final bool error;

  /// The indent a nested value starts at.
  static const initialTab = 1;

  /// One level of indent.
  static const tabStep = '    ';

  /// Whether to report a nested map on one line, rather than one key per line.
  final bool compact;

  /// The width a line is wrapped at.
  final int maxWidth;

  /// Takes each line instead of the logger, for a caller routing them somewhere of its own.
  final LogPrint? logPrint;

  // Consulted before a line is formatted, so a request costs nothing while nothing wants it.
  bool _wants(InterceptStep step) {
    if (logPrint != null) return true;
    return _logger.isLoggable(_priorityOf(step));
  }

  StreamLogPriority _priorityOf(InterceptStep step) {
    return switch (step) {
      InterceptStep.error => StreamLogPriority.warning,
      InterceptStep.request || InterceptStep.response => StreamLogPriority.debug,
    };
  }

  void _write(InterceptStep step, Object object) {
    if (logPrint case final logPrint?) return logPrint(step, object);
    return _logger.log(_priorityOf(step), () => '$object');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_wants(InterceptStep.request)) return super.onRequest(options, handler);

    if (request) {
      _printRequestHeader(_logPrintRequest, options);
    }
    if (requestHeader) {
      _printMapAsTable(
        _logPrintRequest,
        options.queryParameters,
        header: 'Query Parameters',
      );
      final requestHeaders = <String, Object?>{...options.headers};
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      _printMapAsTable(_logPrintRequest, requestHeaders, header: 'Headers');
      _printMapAsTable(_logPrintRequest, options.extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) {
          _printMapAsTable(
            _logPrintRequest,
            options.data as Map?,
            header: 'Body',
          );
        } else if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(
            _logPrintRequest,
            formDataMap,
            header: 'Form data | ${data.boundary}',
          );
        } else {
          _printBlock(_logPrintRequest, data.toString());
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_wants(InterceptStep.error)) return super.onError(err, handler);

    if (error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        _printBoxed(
          _logPrintError,
          header: 'DioException ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage}',
          text: uri.toString(),
        );
        if (err.response != null && err.response?.data != null) {
          _logPrintError('╔ ${err.type}');
          _printResponse(_logPrintError, err.response!);
        }
        _printLine(_logPrintError, '╚');
      } else {
        _printBoxed(
          _logPrintError,
          header: 'DioException ║ ${err.type}',
          text: err.message,
        );
        _printRequestHeader(_logPrintError, err.requestOptions);
      }
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_wants(InterceptStep.response)) return super.onResponse(response, handler);

    _printResponseHeader(_logPrintResponse, response);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers.forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(_logPrintResponse, responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      _logPrintResponse('╔ Body');
      _printResponse(_logPrintResponse, response);
      _printLine(_logPrintResponse, '╚');
    }
    super.onResponse(response, handler);
  }

  void _printBoxed(
    void Function(Object) logPrint, {
    String? header,
    String? text,
  }) {
    // No blank line before the box: each one is a record of its own, carrying a timestamp and a
    // tag, so what separated boxes on a console only pads the log here.
    logPrint('╔╣ $header');
    logPrint('║  $text');
    _printLine(logPrint, '╚');
  }

  void _printResponse(
    void Function(Object) logPrint,
    Response<dynamic> response,
  ) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(logPrint, response.data as Map);
      } else if (response.data is List) {
        logPrint('║${_indent()}[');
        _printList(logPrint, response.data as List);
        logPrint('║${_indent()}[');
      } else {
        _printBlock(logPrint, response.data.toString());
      }
    }
  }

  void _printResponseHeader(
    void Function(Object) logPrint,
    Response<dynamic> response,
  ) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
      logPrint,
      header: 'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}',
      text: uri.toString(),
    );
  }

  void _printRequestHeader(
    void Function(Object) logPrint,
    RequestOptions options,
  ) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(logPrint, header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine(
    void Function(Object) logPrint, [
    String pre = '',
    String suf = '╝',
  ]) => logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(void Function(Object) logPrint, String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(logPrint, msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(void Function(Object) logPrint, String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logPrint(
        (i >= 0 ? '║ ' : '') +
            msg.substring(
              i * maxWidth,
              math.min<int>(i * maxWidth + maxWidth, msg.length),
            ),
      );
    }
  }

  String _indent([int tabCount = initialTab]) => tabStep * tabCount;

  void _printPrettyMap(
    void Function(Object) logPrint,
    Map<dynamic, dynamic> data, {
    int tabs = initialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var indentedTabs = tabs;
    final isRoot = indentedTabs == initialTab;
    final initialIndent = _indent(indentedTabs);
    indentedTabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.replaceAll(RegExp(r'(\r|\n)+'), " ")}"';
      }
      if (value is Map) {
        if (compact) {
          logPrint(
            '║${_indent(indentedTabs)} $key: $value${!isLast ? ',' : ''}',
          );
        } else {
          logPrint('║${_indent(indentedTabs)} $key: {');
          _printPrettyMap(logPrint, value, tabs: indentedTabs);
        }
      } else if (value is List) {
        if (compact) {
          logPrint('║${_indent(indentedTabs)} $key: $value');
        } else {
          logPrint('║${_indent(indentedTabs)} $key: [');
          _printList(logPrint, value, tabs: indentedTabs);
          logPrint('║${_indent(indentedTabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(indentedTabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            logPrint(
              '║${_indent(indentedTabs)} ${msg.substring(
                i * linWidth,
                math.min<int>(i * linWidth + linWidth, msg.length),
              )}',
            );
          }
        } else {
          logPrint('║${_indent(indentedTabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(
    void Function(Object) logPrint,
    List<dynamic> list, {
    int tabs = initialTab,
  }) {
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact) {
          logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            logPrint,
            e,
            tabs: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  void _printMapAsTable(
    void Function(Object) logPrint,
    Map<dynamic, dynamic>? map, {
    String? header,
  }) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    map.forEach(
      (dynamic key, dynamic value) => _printKV(logPrint, key.toString(), value),
    );
    _printLine(logPrint, '╚');
  }

  void _logPrintRequest(Object object) => _write(InterceptStep.request, object);

  void _logPrintResponse(Object object) => _write(InterceptStep.response, object);

  void _logPrintError(Object object) => _write(InterceptStep.error, object);
}
