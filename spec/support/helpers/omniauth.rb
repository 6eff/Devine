module Omniauth
  module Mock
    def auth_mock
      Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
      omniauth_hash = { 'provider' => 'github',
                        'uid' => '12345',
                        'info' => {
                        'name' => 'natasha',
                        'email' => 'hi@natashatherobot.com',
                        'nickname' => 'NatashaTheRobot',
                        'member_since' => "2016-06-06"
                    },
                    credentials: {
          token: "123456",
          expires_at: (Time.now + (2*7*24*60*60)).strftime("%F")
        },
                        'extra' => { 'raw_info' =>
                                    { 'location' => 'San Francisco',
                                      'gravatar_id' => '123456789',
                                      'member_since' => "2016-06-06"
                                      } } }
      OmniAuth.config.add_mock(:github, omniauth_hash)

    end

  end

  module SessionHelpers
    def signin
      visit root_path
      expect(page).to have_content('Sign in')
      auth_mock
      click_link 'Sign in'
      expect(page).to have_content('Welcome, natasha')
    end

    def make_project
      click_link 'My Repos'
      expect(page).to have_button "Share .atom"
      click_button 'Share .atom'
      expect(page.current_path).to eq "/projects/new"
      fill_in 'Description', with: "These are my atom files"
      click_button 'Create Project'
    end
  end

  module MessagingHelpers
    def send_message
      click_link 'Mailbox'
      click_link 'Start conversation'
      fill_in 'Subject', with: 'Test subject'
      fill_in 'Message', with: 'Test message'
      select('natasha', :from => 'Choose recipients')
      click_button 'Send'
    end

    def handle_js_confirm(accept=true)
      page.evaluate_script "window.original_confirm_function = window.confirm"
      page.evaluate_script "window.confirm = function(msg) { return #{!!accept}; }"
      yield
      page.evaluate_script "window.confirm = window.original_confirm_function"
    end
  end
end
