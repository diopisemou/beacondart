class MultiUseCallback {
  final Function(dynamic)? callback;
  final Function(dynamic)? errorCallback;
  final Function(dynamic)? cancelCallback;
  final Function(dynamic)? completeCallback;
  final Function(dynamic)? onErrorCallback;
  final Function(dynamic)? onCancelCallback;
  final Function(dynamic)? onCompleteCallback;
  final Function(dynamic)? onSuccessCallback;
  final Function(dynamic)? onError;
  final Function(dynamic)? onCancel;
  final Function(dynamic)? onComplete;
  final Function(dynamic)? onSuccess;

  MultiUseCallback(
      {this.callback,
      this.errorCallback,
      this.cancelCallback,
      this.completeCallback,
      this.onErrorCallback,
      this.onCancelCallback,
      this.onCompleteCallback,
      this.onSuccessCallback,
      this.onError,
      this.onCancel,
      this.onComplete,
      this.onSuccess});
}
