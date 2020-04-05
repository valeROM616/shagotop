class String
  def is_number?
    true if Float(self) rescue false
  end
end
class Main
  @perem = Hash.new

  def self.confirmation
    Rails.configuration.rest_server[:confirmation_code]
  end

  def self.access_token
    Rails.configuration.rest_server[:community_token]
  end


  def self.set_level(steps, flag)
    case flag
    when 'today', 'yesterday'
      if steps < 1000
        return 'Холоп'
      elsif steps >= 1000 and steps <= 5000
        return 'Боярин'
      elsif steps > 5000 and steps <= 10000
        return 'Феодал'
      elsif steps > 10000 and steps <= 20000
        return 'Царь'
      else
        return 'Боженька'
      end
    when 'all_days'
      if steps < 10000
        return 'Холоп'
      elsif steps > 10000 and steps <= 20000
        return 'Боярин'
      elsif steps > 20000 and steps <= 50000
        return 'Феодал'
      elsif steps > 50000 and steps <= 90000
        return 'Царь'
      else
        return 'Боженька'
      end
    end
  end

  def self.get_full_name(id)
    names = VkWrapper.vk_api(access_token, 'users.get', {:user_ids => id})
    response = {:firstname => names['response'][0]['first_name'], :lastname => names['response'][0]['last_name']}
    return response
  end

  def self.create_text_table(flag)
    message = ''
    case flag
    when 'all_days'
      all_users = User.all
    when 'today'
      all_users = User.where(created_at: Date.today.all_day)
    when 'yesterday'
      all_users = User.where(created_at: Date.yesterday.all_day)
    end
    users = all_users.group(:user_id).pluck('user_id', 'SUM(steps)', 'SUM(length)')
    users.sort_by! { |a, b, c| b }
    users.reverse!
    users = users.first(25)
    users.each_with_index do |elem, index|
      names = get_full_name(elem[0])
      full_name = "#{names[:firstname] } #{names[:lastname]}"
      message = message + "\n |#{index + 1}| #{full_name} | шаги: #{elem[1]} | километры: #{elem[2]}| #{set_level(elem[1], flag)}"
    end
    message
  end

  def self.get_rank(id)
    users = User.all.group(:user_id).pluck('user_id', 'SUM(steps)', 'SUM(length)').sort_by! { |a, b, c| c }
    users.reverse!
    users.map { |elem| elem[0] }.find_index(id) + 1
  end

  def self.keyboard(flag)
    if flag == true
      notif = 'Отключить уведомления'
      color = 'negative'
    else
      notif = 'Включить уведомления'
      color = 'positive'
    end
    keyboard = {
        "one_time": false,
        "buttons": [
            [{
                 "action": {
                     "type": "text",
                     "payload": "{\"button\": \"1\"}",
                     "label": "Топ"
                 },
                 "color": "secondary"
             },
             {
                 "action": {
                     "type": "text",
                     "payload": "{\"button\": \"2\"}",
                     "label": "Топ сегодня"
                 },
                 "color": "secondary"
             },
             {
                 "action": {
                     "type": "text",
                     "payload": "{\"button\": \"2\"}",
                     "label": "Топ вчера"
                 },
                 "color": "secondary"
             },
            ],
            [{
                 "action": {
                     "type": "text",
                     "payload": "{\"button\": \"1\"}",
                     "label": "Ранг"
                 },
                 "color": "secondary"
             },
             {
                 "action": {
                     "type": "text",
                     "label": "Правила"
                 },
                 "color": "secondary"
             },
             {
                 "action": {
                     "type": "text",
                     "label": "Уровни"
                 },
                 "color": "secondary"
             }
            ],
            [{
                 "action": {
                     "type": "text",
                     "label": "Топ текстом"
                 },
                 "color": "secondary"
             }],
            [
                {
                    "action": {
                        "type": "text",
                        "label": notif
                    },
                    "color": color
                }
            ]
        ]
    }
    keyboard.to_json
  end

  def self.get_html(flag)
    case flag
    when 'all_days'
      all_users = UserList.all.pluck(:user_id, :steps, :length)
    when 'today'
      all_users = User.where(created_at: Date.today.all_day)
    when 'yesterday'
      all_users = User.where(created_at: Date.yesterday.all_day)
    end
    html = '<table><col width="25"><col width="180">'
    html = html + '<meta charset="utf-8">'
    html = html + '<tr><th>№</th><th>Участник</th><th>Шаги</th><th>Километры</th><th>Уровень</th></tr>'
    if flag != 'all_days'
      users = all_users.group(:user_id).pluck('user_id', 'SUM(steps)', 'SUM(length)')
    else
      users = all_users
    end
    users.sort_by! { |a, b, c| c }
    users.reverse!
    users = users.first(25)
    users.each_with_index do |elem, index|
      names = get_full_name(elem[0])
      full_name = "#{names[:firstname] } #{names[:lastname]}"
      html = html + "<tr><td>#{index + 1}</td><td>#{full_name}</td><td>#{elem[1]}</td><td>#{elem[2].round(2)}</td><td>#{set_level(elem[1], flag)}</td></tr>"
    end
    html = html + '</table>'
  end

  def self.get_image(flag)
    path = "/home/valerom/chat-bot-api/images/"
    File.exist?("#{flag}.jpg") ? FileUtils.remove("#{flag}.jpg") : 'ok'
    kit = IMGKit.new(get_html(flag), :width => 500)
    kit.stylesheets << '/home/valerom/chat-bot-api/public/table.css'
    kit.to_file(path + "#{flag}.jpg")
  end

  def self.upload_image(flag, id)
    get_image(flag)
    response = VkWrapper.vk_api(access_token, 'photos.getMessagesUploadServer', {})
    url = response['response']['upload_url']
    resp = HTTP.post(url, :form => {
        photo: HTTP::FormData::File.new("/home/valerom/chat-bot-api/images/#{flag}.jpg")
    })
    keys = JSON.parse(resp)
    ans = VkWrapper.vk_api(access_token, 'photos.saveMessagesPhoto', {:server => keys['server'], :photo => keys['photo'], :hash => keys['hash']})
    photo_name = "photo#{ans['response'][0]['owner_id']}_#{ans['response'][0]['id']}}"
    VkWrapper.vk_api(access_token, 'messages.send', {:peer_id => id, :attachment => photo_name})
  end

  def self.users_to_send
    users = UserList.where(:flag => true).pluck(:user_id).uniq!
    users.each do |id|
      VkWrapper.vk_api(access_token, 'messages.send', {:peer_id => id, :message => "Время отчитаться"})
    end
  end

  def self.on_off_notif(id)
    user = UserList.where(:user_id => id)[0]
    if user.flag == true
      user.flag = false
    else
      user.flag = true
    end
    user.save!
  end

  def self.send_message(props)
    case props[:type]
    when 'message_new'
      peer_id = props[:object][:peer_id]

      text = props[:object][:text]
      text = text.downcase.split

      if text[0] == 'топ'
        if text[1] == nil
          upload_image('all_days', peer_id)
        elsif text[1] == 'текстом'
          message = create_text_table('all_days')
        elsif text[1] == 'сегодня'
          upload_image('today', peer_id)
        elsif text[1] == 'вчера'
          upload_image('yesterday', peer_id)
        else
          message = 'Недопустимая команда'
        end
      elsif text[0] == 'уровни'
        message = "Уровни достигаются накапливанием шагов: \n <10000 - Холоп
                   10000 - 20000 - Боярин\n 20001 - 50000 - Феодал\n 50001 - 90000 - Царь\n >90001 - Боженька "
      elsif text[0] == 'правила'
        message = "Для участия в этом соревновании необходимо ежедневно ходить и попутно бить рекорды своих коллег и себя самого. Когда прошли какое-то расстояние, напишите  боту количество шагов и количество пройденных километров, например \"5600 2\" без кавычек"
      elsif text[0] == 'ранг'
        message = "Вы занимаете #{get_rank(peer_id)} позицию"
      elsif text[0] == 'отключить' || 'включить'
        on_off_notif(peer_id)
        message = 'Действие применено'
      elsif text[0].is_number?
        if text[0].to_f > text[1].to_f
          if !text[1].nil? && text[1][0].is_number?
            text[1].sub! ',', '.'
            User.create('user_id': peer_id, 'steps': text[0], 'length': text[1])
            if UserList.pluck(:user_id).include? peer_id
              user = UserList.where(:user_id => peer_id)[0]
              user.steps += text[0].to_i
              user.length += text[1].to_f
              user.save!
            else
              names = get_full_name(peer_id)
              UserList.create(:user_id => peer_id,
                              :firstname => names[:firstname],
                              :lastname => names[:lastname],
                              :steps => text[0],
                              :length => text[1],
                              :flag => true)
            end
            message = "Шаги успешно записаны"
          elsif text[1].nil? || !text[1].is_number?
            message = "Необходимо указать и пройденные километры вторым числом"
          end
        else
          message = "Давай будем честными перед самими собой. Километров #{text[1]}, а шагов всего #{text[0]}?"
        end
      else
        message = 'Недопустимая команда'
      end

      params = {
          :message => message,
          :peer_id => peer_id,
          :keyboard => keyboard(UserList.where(:user_id => peer_id)[0].flag)
      }
      VkWrapper.vk_api(access_token, 'messages.send', params)

    else
      print("ok")
    end
  end
end
