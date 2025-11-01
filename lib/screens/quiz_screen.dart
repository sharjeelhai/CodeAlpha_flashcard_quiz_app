import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class QuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const QuizScreen({super.key, required this.flashcards});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showAnswerPressed() {
    setState(() => _showAnswer = true);
    _flipController.forward();
  }

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      _slideController.forward().then((_) {
        setState(() {
          _currentIndex++;
          _showAnswer = false;
        });
        _flipController.reset();
        _slideController.reset();
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _slideController.forward().then((_) {
        setState(() {
          _currentIndex--;
          _showAnswer = false;
        });
        _flipController.reset();
        _slideController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text('No flashcards available'),
        ),
      );
    }

    final currentCard = widget.flashcards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz (${_currentIndex + 1}/${widget.flashcards.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.flashcards.length,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Flashcard
            Expanded(
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: _showAnswer ? null : _showAnswerPressed,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final isShowingFront = _flipAnimation.value < 0.5;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_flipAnimation.value * 3.14159),
                          child: Card(
                            elevation: 12,
                            child: Container(
                              width: double.infinity,
                              height: 300,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isShowingFront
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.secondaryContainer,
                                    isShowingFront
                                        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8)
                                        : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(isShowingFront ? 0 : 3.14159),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isShowingFront ? Icons.help_outline : Icons.lightbulb_outline,
                                      size: 48,
                                      color: isShowingFront
                                          ? Theme.of(context).colorScheme.onPrimaryContainer
                                          : Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isShowingFront ? 'Question' : 'Answer',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: isShowingFront
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : Theme.of(context).colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          isShowingFront ? currentCard.question : currentCard.answer,
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: isShowingFront
                                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                                : Theme.of(context).colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Controls
            if (!_showAnswer)
              ElevatedButton.icon(
                onPressed: _showAnswerPressed,
                icon: const Icon(Icons.visibility),
                label: const Text('Show Answer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentIndex < widget.flashcards.length - 1 ? _nextCard : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}