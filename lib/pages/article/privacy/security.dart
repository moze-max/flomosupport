import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Security extends StatefulWidget {
  const Security({super.key});

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  bool _systemNotificationEnabled = true;
  bool _notificationPreviewEnabled = true;
  bool _voiceVideoCallReminderEnabled = true;
  bool _qqMessageBannerEnabled = true;
  bool _doNotDisturbEnabled = false;
  bool _qqBirthdayReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // 在实际应用中，点击返回会退出当前页面
          },
        ),
        title: Center(
          child: Text(
            appLocalizations.personalInfoProtection,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('未打开QQ时'),
            _buildToggleItem(
              '系统消息通知',
              _systemNotificationEnabled,
              (bool value) {
                setState(() {
                  _systemNotificationEnabled = value;
                });
              },
              icon: Icons.notifications_none,
            ),
            _buildDivider(),
            _buildToggleItem(
              '通知显示消息预览',
              _notificationPreviewEnabled,
              (bool value) {
                setState(() {
                  _notificationPreviewEnabled = value;
                });
              },
              icon: Icons.remove_red_eye_outlined,
            ),
            _buildDivider(),
            _buildToggleItem(
              '语音和视频通话提醒',
              _voiceVideoCallReminderEnabled,
              (bool value) {
                setState(() {
                  _voiceVideoCallReminderEnabled = value;
                });
              },
              icon: Icons.call,
            ),
            _buildSectionHeader('打开QQ时'),
            _buildToggleItem(
              'QQ内消息横幅',
              _qqMessageBannerEnabled,
              (bool value) {
                setState(() {
                  _qqMessageBannerEnabled = value;
                });
              },
              icon: Icons.amp_stories_outlined,
            ),
            _buildSectionHeader('提醒方式'),
            _buildMenuItem(
              '声音',
              Icons.volume_up,
              () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              '振动',
              Icons.vibration,
              () {},
            ),
            _buildDivider(),
            _buildToggleItem(
              '勿扰模式',
              _doNotDisturbEnabled,
              (bool value) {
                setState(() {
                  _doNotDisturbEnabled = value;
                });
              },
              description: '打开后在指定时间内不接收信...',
              icon: Icons.do_not_disturb_on_outlined,
            ),
            _buildSectionHeader('通知内容'),
            _buildToggleItem(
              'QQ提醒好友生日',
              _qqBirthdayReminderEnabled,
              (bool value) {
                setState(() {
                  _qqBirthdayReminderEnabled = value;
                });
              },
              icon: Icons.cake,
            ),
            _buildDivider(),
            _buildMenuItem(
              '订阅号消息',
              Icons.rss_feed,
              () {},
            ),
            _buildDivider(),
            _buildMenuItem(
              '特别关心',
              Icons.favorite_border,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  // 构建每个部分的标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建带滑动开关的列表项
  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? description,
    IconData? icon,
  }) {
    return Container(
      color: Colors.grey[850],
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.white70) : null,
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: description != null
            ? Text(
                description,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              )
            : null,
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveTrackColor: Colors.grey[700],
            activeTrackColor: Colors.blue[700],
            inactiveThumbColor: Colors.grey[300],
          ),
        ),
        onTap: () {
          onChanged(!value);
        },
      ),
    );
  }

  // 构建带右侧箭头的菜单项 (没有开关)
  Widget _buildMenuItem(
    String title,
    IconData? icon,
    VoidCallback onTap,
  ) {
    return Container(
      color: Colors.grey[850],
      child: ListTile(
        leading: icon != null ? Icon(icon, color: Colors.white70) : null,
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // 构建分隔线
  Widget _buildDivider() {
    return Container(
      color: Colors.grey[850],
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.black,
        indent: 16,
        endIndent: 0,
      ),
    );
  }
}
