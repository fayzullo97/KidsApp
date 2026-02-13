import 'package:flutter/material.dart';
import 'package:kids_learning_app/models/feed_item.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class QuestionWidget extends StatefulWidget {
  final QuestionItemData question;
  final VoidCallback onCorrect;

  const QuestionWidget({
    super.key, 
    required this.question,
    required this.onCorrect,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(bool correct) async {
    try {
      // Using generic sound URLs for MVP. 
      // In production, these should be local assets.
      if (correct) {
         await _audioPlayer.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/bonus.wav'));
      } else {
         await _audioPlayer.play(UrlSource('https://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/explosion_02.wav'));
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _handleAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    if (index == widget.question.correctIndex) {
      _confettiController.play();
      _playSound(true);
      widget.onCorrect();
    } else {
      _playSound(false);
      // Wrong answer logic (shake or sound)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.question.questionText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Options Grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(widget.question.options.length, (index) {
                  final isSelected = _selectedIndex == index;
                  final isCorrect = index == widget.question.correctIndex;
                  
                  Color color = Colors.blue.shade100;
                  if (_answered) {
                    if (isSelected) {
                      color = isCorrect ? Colors.green.shade300 : Colors.red.shade300;
                    } else if (isCorrect) {
                       color = Colors.green.shade100; // Show correct answer
                    }
                  }

                  return GestureDetector(
                    onTap: () => _handleAnswer(index),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                         child: Text(
                           widget.question.options[index],
                           style: const TextStyle(fontSize: 18),
                           textAlign: TextAlign.center,
                         ),
                         // In real app, this would be an image
                      ),
                    ),
                  );
                }),
              ),
              if (_answered) ...[
                 const SizedBox(height: 32),
                 if (_selectedIndex == widget.question.correctIndex)
                   const Text('Correct! Great Job!', style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold))
                 else
                   const Text('Oops, try again next time!', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                 
                 const SizedBox(height: 16),
                 const Text('Swipe down to continue', style: TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}
