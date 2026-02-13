# Product Requirements Document (PRD)

## Adaptive Learning Video App for Children (Ages 1--4)

------------------------------------------------------------------------

# 1. Product Overview

## 1.1 Vision

Build an AI-powered adaptive learning mobile application that teaches
essential early childhood knowledge (ages 1--4) through short vertical
videos (5--20 seconds), automatically personalized based on each child's
learning progress.

The app must intelligently adjust content difficulty and repetition
using an adaptive algorithm to maximize learning efficiency while
keeping the experience engaging and age-appropriate.

------------------------------------------------------------------------

# 2. Objectives

### Primary Objectives

-   Deliver structured early childhood education via short-form video
-   Personalize content automatically per child
-   Track learning progress at a granular level
-   Adapt content frequency based on mastery
-   Ensure safe, non-addictive engagement

### Success Metrics (KPIs)

-   Daily active usage rate
-   Average session length (age-appropriate)
-   Mastery progression rate
-   Correct answer rate improvement over time
-   Content completion coverage per curriculum

------------------------------------------------------------------------

# 3. Target Users

### Primary Users

-   Children aged 1--4

### Secondary Users

-   Parents (setup, monitoring progress)

------------------------------------------------------------------------

# 4. User Flow

## 4.1 First Launch Experience

1.  Parent enters:
    -   Child's name
    -   Child's age (1--4)
2.  System loads age-specific curriculum
3.  Initial adaptive model state is created
4.  Learning goals are automatically assigned

------------------------------------------------------------------------

# 5. Core Learning Model

## 5.1 Knowledge Structure

### Hierarchy:

-   Curriculum
    -   Topics (Fruits, Animals, Drinks, Toys, etc.)
        -   Knowledge Units (Apple, Orange, Dog, Cat, etc.)
            -   Videos (5+ per unit)
            -   Questions

------------------------------------------------------------------------

# 6. Adaptive Learning System

## 6.1 Mastery Model

Each knowledge unit has a **Mastery Score (M)** between 0 and 1.

### Mastery Formula (Example)

M = (Correct Answers / Total Attempts) × Confidence Factor

Where: - Confidence Factor increases with repetition - Decays over time
using forgetting curve

### Mastery Threshold

A knowledge unit is considered "Learned" when:

-   ≥ 10 correct answers
-   Across spaced repetitions
-   Over multiple sessions

------------------------------------------------------------------------

## 6.2 Forgetting Curve Logic

Retention(t) = M × e\^(-λt)

Where: - λ = forgetting rate - t = time since last correct answer

------------------------------------------------------------------------

# 7. Content Selection Algorithm

## 7.1 Design Principles

-   Prioritize weak knowledge areas
-   Maintain cross-topic diversity
-   Prevent repetition fatigue
-   Maintain natural feed randomness

## 7.2 Weighted Probability Model

Weight = (1 − M) + Exploration Bonus

## 7.3 Pseudocode

    function selectNextVideo(user):

        topics = getAllTopics()

        diversifyTopics(topics)

        for each knowledgeUnit in topics:
            mastery = getMastery(user, knowledgeUnit)
            decayAdjustedMastery = applyForgettingCurve(mastery)
            weight = (1 - decayAdjustedMastery) + explorationBonus

        selectedUnit = weightedRandomSelection(knowledgeUnits)

        video = randomVideoFromUnit(selectedUnit)

        return video

------------------------------------------------------------------------

# 8. Question & Assessment Logic

-   After every 5 videos → 1 interactive question
-   Questions correspond to recently shown knowledge units
-   Result updates mastery score
-   Immediate positive reinforcement provided

------------------------------------------------------------------------

# 9. Progress Tracking System

## 9.1 Per-User Data Structure

For each child:

-   KnowledgeUnitID
    -   VideosWatchedCount
    -   CorrectAnswers
    -   WrongAnswers
    -   MasteryScore
    -   LastInteractionTime

------------------------------------------------------------------------

# 10. Personalization Layer

## 10.1 Age-Based Adaptation

  Age   Video Length   Question Frequency   Complexity
  ----- -------------- -------------------- ------------------
  1     5--8 sec       Every 7 videos       Recognition only
  2     5--10 sec      Every 5 videos       Simple matching
  3     10--15 sec     Every 4 videos       Multi-choice
  4     15--20 sec     Every 3 videos       Categorization

------------------------------------------------------------------------

# 11. Scalability Design

Designed for: - 1,000+ knowledge units - 50,000+ videos - Millions of
users

------------------------------------------------------------------------

# 12. Safety & UX Guidelines

-   Soft colors
-   Calm background sounds
-   No flashing animations
-   No manipulative mechanics

------------------------------------------------------------------------

# 13. Definition of Done

-   Adaptive model dynamically adjusts content
-   Mastery is accurately tracked
-   Cross-topic diversity is preserved
-   Learning efficiency improves over time
-   UX is safe and age-appropriate
-   Scales to millions of users

------------------------------------------------------------------------

**End of PRD**
