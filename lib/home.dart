import 'package:flutter/material.dart';
import 'package:main1/main.dart';

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  bool _isDarkMode = true; // Default to dark mode

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home with Theme Toggle',
      theme: _isDarkMode ? _darkTheme() : _lightTheme(),
      home: Home(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 1, 30, 1), 
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromRGBO(0, 77, 64, 1), 
        titleTextStyle: TextStyle(
          color: Colors.yellow.shade100, 
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.yellow.shade100),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.yellow.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.yellow.shade100,
        titleTextStyle: const TextStyle(
          color: Color(0xFF004D40),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF004D40)),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const Home({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final Map<DateTime, List<String>> _events = {
    DateTime(2025, 7, 15): ['Team Meeting', 'Project Review'],
    DateTime(2025, 7, 20): ['Doctor Appointment'],
    DateTime(2025, 7, 25): ['Birthday Party', 'Dinner with friends'],
    DateTime(2025, 8, 1): ['Monthly Report Due'],
    DateTime(2025, 8, 5): ['Conference Call'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year && day1.month == day2.month && day1.day == day2.day;
  }

  // Color schemes for both themes
  Color get _backgroundColor => widget.isDarkMode ? const Color.fromARGB(255, 1, 30, 1) : Colors.yellow.shade50;
  Color get _primaryColor => widget.isDarkMode ? const Color.fromRGBO(0, 77, 64, 1) : Colors.yellow.shade100;
  Color get _textColor => widget.isDarkMode ? Colors.yellow.shade100 : const Color(0xFF004D40);
  Color get _subtleTextColor => widget.isDarkMode ? Colors.yellow.shade100.withOpacity(0.7) : const Color(0xFF004D40).withOpacity(0.7);
  Color get _cardColor => widget.isDarkMode ? const  Color(0xFF004D40).withOpacity(0.3) : Colors.yellow.shade100.withOpacity(0.5);
  Color get _accentColor => widget.isDarkMode ? Colors.yellow.shade100 : const  Color(0xFF004D40);

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: 42, // 6 weeks * 7 days
      itemBuilder: (context, index) {
        final dayOffset = index - firstWeekday;
        
        if (dayOffset < 0 || dayOffset >= daysInMonth) {
          return Container(); // Empty cell
        }
        
        final day = dayOffset + 1;
        final currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = _isSameDay(currentDate, DateTime.now());
        final isSelected = _isSameDay(currentDate, _selectedDate);
        final hasEvents = _getEventsForDay(currentDate).isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected 
                  ? _accentColor.withOpacity(0.3)
                  : isToday 
                      ? _primaryColor
                      : Colors.transparent,
              border: Border.all(
                color: isToday 
                    ? _accentColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected || isToday
                          ? (widget.isDarkMode ? Colors.yellow.shade100 : const Color(0xFF004D40))
                          : _subtleTextColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDate);
    
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No events for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: TextStyle(
              color: _subtleTextColor,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...events.map((event) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: _accentColor,
                width: 4.0,
              ),
            ),
          ),
          child: Text(
            event,
            style: TextStyle(
              color: _textColor,
              fontSize: 16,
            ),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: Drawer(
        child: Container(
          color: _primaryColor,
          child: Column(
            children: [
              // Drawer Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 64,
                      color: _textColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'User Menu',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.home,
                        color: _textColor,
                      ),
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: _textColor,
                      ),
                      title: Text(
                        'Calendar',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Calendar feature coming soon!'),
                            backgroundColor: _accentColor,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: _textColor,
                      ),
                      title: Text(
                        'Settings',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Settings feature coming soon!'),
                            backgroundColor: _accentColor,
                          ),
                        );
                      },
                    ),
                    
                    ListTile(
                      leading: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: _textColor,
                      ),
                      title: Text(
                        widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Switch(
                        value: widget.isDarkMode,
                        onChanged: (value) {
                          widget.onThemeToggle();
                          Navigator.pop(context);
                        },
                        activeColor: _accentColor,
                        inactiveThumbColor: _textColor.withOpacity(0.7),
                        inactiveTrackColor: _textColor.withOpacity(0.3),
                      ),
                      onTap: () {
                        widget.onThemeToggle();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeButtons()),
                        (route) => false, 
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: Icon(Icons.menu, color: _textColor),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Home',
          style: TextStyle(
            color: _textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today is ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      color: _subtleTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                          });
                        },
                        icon: Icon(
                          Icons.chevron_left,
                          color: _textColor,
                        ),
                      ),
                      Text(
                        '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                          });
                        },
                        icon: Icon(
                          Icons.chevron_right,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: _subtleTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  _buildCalendarGrid(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildEventsList(),
            
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: widget.isDarkMode ? const Color(0xFF004D40) : Colors.yellow.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Add Event feature coming soon!'),
                                backgroundColor: _accentColor,
                              ),
                            );
                          },
                          child: const Text('Add Event'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: _accentColor,
                            side: BorderSide(color: _accentColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime.now();
                              _currentMonth = DateTime.now();
                            });
                          },
                          child: const Text('Today'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
