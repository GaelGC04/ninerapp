import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';
import 'dart:async';

import 'package:ninerapp/presentation/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final bool currentUserIsParent;
  final Parent parent;
  final Babysitter babysitter;

  const ChatScreen({
    super.key,
    required this.currentUserIsParent,
    required this.parent,
    required this.babysitter,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Map<int, String> _babysitterMessages = {1: 'Hola de niñero'};
  final Map<int, String> _parentMessages = {2: 'Hola de padre'};

  bool _isLoading = false;
  String _errorMessage = "";

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _startMessagePolling();
  }

  void _startMessagePolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // if (mounted) loadMessages();
      
      _scrollToBottom();
    });
  }

  void loadMessages() {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    
    try {
      // final messages = await _chatRepository.getMessages(widget.service.id!);
       // TODO obtneer mensajes de bd
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el chat: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (widget.currentUserIsParent) {
        final newId = [..._parentMessages.keys, ..._babysitterMessages.keys].reduce((a, b) => a > b ? a : b) + 1;
        _parentMessages[newId] = text;
      } else {
        final newId = [..._parentMessages.keys, ..._babysitterMessages.keys].reduce((a, b) => a > b ? a : b) + 1;
        _babysitterMessages[newId] = text;
      }
      
      _messageController.clear();
      
      _scrollToBottom();
    });
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMessages = {..._parentMessages, ..._babysitterMessages};
    final sortedKeys = allMessages.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Chat: ${widget.currentUserIsParent == true ? widget.babysitter.name : widget.parent.name}", style: AppTextstyles.appBarText),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.currentSectionColor))
                : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: AppTextstyles.bodyText.copyWith(color: AppColors.red), textAlign: TextAlign.center))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final key = sortedKeys[index];
                        final message = allMessages[key]!;
                        
                        final isCurrentUserMessage = widget.currentUserIsParent == true
                          ? _parentMessages.containsKey(key)
                          : _babysitterMessages.containsKey(key);

                        return MessageBubble(
                          message: message,
                          isSender: isCurrentUserMessage,
                        );
                      },
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10, right: 15, left: 20, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _messageController,
                    hintText: "Mensaje:",
                    validation: (){},
                  )
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50, width: 50,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.currentSectionColor,
                    elevation: 2,
                    shape: const CircleBorder(),
                    onPressed: _sendMessage,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 2, left: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.paperPlane, size: 20, color: AppColors.white),
                          SizedBox(width: 6)
                        ],
                      ),
                    ),
                  ),
                )
              ]
            )
          )
        ],
      ),
    );
  }
}