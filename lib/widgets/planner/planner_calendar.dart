import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class PlannerCalendar extends StatelessWidget {
  const PlannerCalendar({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime? selectedDate;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdayStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final baseDayColor = theme.textTheme.bodyMedium?.color;

    return Calendar(
      initialDate: selectedDate ?? focusedMonth,
      startOnMonday: false,
      weekDays: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      onDateSelected: onDateSelected,
      onMonthChanged: onMonthChanged,
      dayBuilder: (context, day) => _buildDayTile(context, day, theme),
      isExpanded: true,
      hideTodayIcon: true,
      showEventListViewIcon: false,
      showEvents: false,
      locale: 'en_US',
      selectedColor: Colors.transparent,
      selectedTodayColor: Colors.transparent,
      todayColor: Colors.transparent,
      defaultDayColor: _applyOpacity(baseDayColor, 0.65),
      defaultOutOfMonthDayColor: _applyOpacity(baseDayColor, 0.25),
      dayOfWeekStyle: weekdayStyle,
      displayMonthTextStyle: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      bottomBarTextStyle: theme.textTheme.bodyMedium,
      expandableDateFormat: 'yyyy년 M월 d일 EEEE',
    );
  }

  Widget _buildDayTile(BuildContext context, DateTime date, ThemeData theme) {
    final bool isInFocusedMonth =
        date.month == focusedMonth.month && date.year == focusedMonth.year;
    final bool isSelected =
        selectedDate != null &&
        DateUtils.isSameDay(date, selectedDate!) &&
        isInFocusedMonth;
    final bool isToday =
        DateUtils.isSameDay(date, DateTime.now()) && isInFocusedMonth;
    final bool isOutOfMonth = !isInFocusedMonth;
    final bool isSunday = date.weekday == DateTime.sunday;
    final bool isSaturday = date.weekday == DateTime.saturday;

    final baseTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    Color textColor = baseTextColor;
    Color? background;

    if (isSelected) {
      background = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      background = _applyOpacity(theme.colorScheme.primaryContainer, 0.85);
      textColor = theme.colorScheme.onPrimaryContainer;
    } else if (isSunday || isSaturday) {
      textColor = isSunday ? Colors.redAccent : Colors.blueAccent;
    }

    if (!isSelected && !isToday) {
      final opacity = isOutOfMonth ? 0.25 : 0.8;
      final alpha = (opacity * 255).round().clamp(0, 255);
      textColor = textColor.withAlpha(alpha);
    }

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Text(
          '${date.day}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected || isToday
                ? FontWeight.w600
                : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Color? _applyOpacity(Color? color, double opacity) {
    if (color == null) return null;
    final int alpha = (opacity * 255).round().clamp(0, 255);
    return color.withAlpha(alpha);
  }
}
