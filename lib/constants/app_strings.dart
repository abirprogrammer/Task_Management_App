class AppStrings {
  static const String appName = "TaskMaster Pro";
  static const String welcomeBack = "Welcome Back!";
  static const String loginSubtitle = "Log in to manage your daily tasks efficiently";
  static const String registerTitle = "Create Account";
  static const String registerSubtitle = "Sign up to start organizing your projects & tasks";
  
  static const String emailHint = "Enter your email";
  static const String passwordHint = "Enter your password";
  static const String nameHint = "Enter your full name";
  
  static const String loginButton = "Login";
  static const String registerButton = "Register";
  
  static const String noAccount = "Don't have an account? ";
  static const String hasAccount = "Already have an account? ";
  static const String signUp = "Sign Up";
  static const String signIn = "Sign In";
  
  static const String myTasks = "My Tasks";
  static const String searchTasks = "Search tasks...";
  static const String addTask = "Add New Task";
  static const String editTask = "Edit Task";
  static const String taskTitle = "Task Title";
  static const String taskDescription = "Description";
  static const String category = "Category";
  static const String dueDate = "Due Date";
  static const String priority = "Priority";
  
  static const String save = "Save Task";
  static const String update = "Update Task";
  static const String cancel = "Cancel";
  
  static const String profile = "Profile";
  static const String logout = "Logout";

  static const String termsAndConditionsTitle = "Terms & Condition";
  static const String termsAndConditionsContent = """Terms & Conditions
Welcome to the Task Manager App. By accessing or using this application, you agree to the following terms and conditions:

1. Use of the App
This app is designed to help users create, manage, and track personal or professional tasks efficiently. By using the app, you agree to use it responsibly and only for lawful purposes.

2. Accuracy of Information
All tasks, notes, and other information entered by the user are stored securely. While we strive to maintain accurate task management functionality, the app is not responsible for missed deadlines, incorrect entries, or user-generated errors.

3. User Responsibility
Users are solely responsible for managing their tasks, reminders, and any personal or professional outcomes related to the completion or non-completion of tasks created within the app.

4. Data Collection
We respect your privacy. The Task Manager App may collect limited personal data (such as name, email, and usage patterns) solely for improving user experience. No data is shared with third parties without user consent.

5. Limitation of Liability
We are not liable for any loss of productivity, missed deadlines, or damages resulting from your use of the app. The app is a productivity tool and should be used at your discretion.

6. Third-Party Links
If the app connects to any third-party tools (e.g., calendar, email), we are not responsible for their data policies or service availability. Use of such services is subject to their respective terms.

7. Changes to Terms
We reserve the right to update these Terms & Conditions at any time. Continued use of the app following any changes will constitute your acceptance of those revised terms.""";

  static const String privacyPolicyTitle = "Privacy Policy";
  static const String privacyPolicyContent = """Privacy Policy – Task Manager App
Your privacy is important to us. This Privacy Policy outlines how the Task Manager App handles your information and protects your data.

1. Information Collection
The Task Manager App may collect limited information such as your name, email address, and preferences — strictly for the purpose of enhancing your task management experience. We do not collect sensitive personal information unnecessarily.

2. Local Storage
Your tasks, subtasks, and user preferences are securely stored in our system or locally on your device (depending on platform settings). This data is used solely to support the app's features like scheduling, notifications, and user customization.

3. No Tracking
We do not use third-party trackers or intrusive analytics tools to monitor your behavior. Any performance monitoring is strictly anonymized and used internally to improve the app experience.

4. Static Data Display
If the app integrates with external tools (e.g., calendar, cloud storage), those services are governed by their own privacy policies. We do not control or assume responsibility for their data handling practices.

5. Third-Party Services
We implement industry-standard measures to ensure your information is protected from unauthorized access, alteration, or misuse. This includes encryption, secure servers, and routine maintenance.

6. Data Security
You retain full control over your account data. You can delete or export your tasks and personal information at any time through your profile settings (if applicable).

7. Policy Updates
This Privacy Policy may be updated periodically. Any changes will be clearly communicated within the app. Continued use after updates indicates your acceptance of the revised policy.  f you have any questions or concerns regarding privacy, please contact us at support@taskmanagerapp.com.""";

  static const String helpSupportTitle = "Help/Support";
  static const String faqsHeading = "FAQs";
  static const String needMoreHelpHeading = "Need More Help?";
  static const String mailUsLabel = "Mail Us: ";
  static const String supportEmail = "support@taskmanagerapp.com";
  static const String supportDesc = "Our help desk is available 24/7 to support your workflow.";

  static const List<Map<String, String>> faqList = [
    {
      'question': 'How do I create a new task?',
      'answer': 'Tap the "Add Task" button on the navigation bar. Fill in the task title, due date, priority, and other details — then tap "Save".'
    },
    {
      'question': 'How can I view task details?',
      'answer': 'Tap on any task card from your "My Tasks" dashboard to open its complete details view, where you can also edit or delete it.'
    },
    {
      'question': 'Can I mark a task as favorite or important?',
      'answer': 'Yes, you can set task priority as Low, Medium, or High when creating or editing a task to highlight important items.'
    },
    {
      'question': 'How do I edit or delete a task?',
      'answer': 'Open the task details view by tapping on a task card. From there, you can tap the edit icon or delete button.'
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, your tasks and account details are securely stored on our backend server with encrypted authentication and password protection.'
    },
  ];
}
