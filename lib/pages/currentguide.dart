import 'dart:developer' as developer;
import 'package:flomosupport/functions/api_service.dart';
import 'package:flomosupport/functions/handle_delete_template.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flomosupport/pages/guideitemshare.dart';

class Currentguide extends StatefulWidget {
  final Template template;
  const Currentguide({super.key, required this.template});

  @override
  State<Currentguide> createState() => _CurrentguideState();
}

class _CurrentguideState extends State<Currentguide> {
  final storage = FlutterSecureStorage();
  String? savedKey;
  late Map<String, TextEditingController> controllers;
  bool _isSubmitting = false;
  final Future<ApiService> _apiServiceInstanceFuture = ApiService.create();

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var item in widget.template.items) item: TextEditingController(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              bool deletedSuccessfully = await handleDeleteTemplateLogic(
                  context: context, templateToDelete: widget.template);
              if (deletedSuccessfully) {
                if (!context.mounted) {
                  return;
                }
                Navigator.pop(context, true);
                // 返回 true 给 Guide 页面，表示需要刷新
              }
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareImageWithTemplatePage(
                    initialTemplateData: widget.template,
                  ),
                ),
              );
            },
            icon: Icon(Icons.share),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.template.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ...widget.template.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controllers[item],
                    decoration: InputDecoration(
                      labelText: item,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    Map<String, dynamic> formData = {};
    controllers.forEach((key, value) {
      formData[key] = value.text;
    });

    String formattedContent = formData.entries
        .map((entry) => "${entry.key}\n${entry.value}\n")
        .join("\n");

    bool success = false;
    String message = '提交失败';

    try {
      // success = await _apiService.sendData(formattedContent);
      final ApiService apiService =
          await _apiServiceInstanceFuture; // <--- 关键修改
      success = await apiService
          .sendData(formattedContent); // <--- 现在在实际的 ApiService 实例上调用
      if (success) {
        message = '发送成功！';
      }
    } catch (e) {
      developer.log('提交过程中发生错误: $e');
      message = '提交失败: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  // Future<void> _handleDeleteTemplate() async {
  //   final contextCopy = context;

  //   bool deleted = await StorageService.deleteTemplate(widget.template);

  //   if (contextCopy.mounted) {
  //     if (deleted) {
  //       showSnackbar(contextCopy, '模板已删除');
  //       // Pop the current route if deletion was successful
  //       if (contextCopy.mounted) {
  //         Navigator.pop(contextCopy, true);
  //       }
  //     } else {
  //       showSnackbar(contextCopy, '删除模板失败', isError: true);
  //     }
  //   }
  // }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
