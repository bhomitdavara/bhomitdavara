// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import "../stylesheets/active_admin";
import "@activeadmin/activeadmin";
import "@fortawesome/fontawesome-free/css/all.css";
import 'arctic_admin'
import '@rootstrap/activeadmin-chat';
import 'activeadmin_quill_editor'
import '@codevise/activeadmin-searchable_select';

$(document).ready(function () {
  var url = window.location.href;
  console.log(gon.host)
  $("#search").keyup(function () {
    const token = document.querySelector('meta[name="csrf-token"]').content
    $.ajax({
      url: "/admin/chat",
      type: "GET",
      dataType: 'script',
      data: { search: $("#search").val() }
    })
  })

  $('head').append("<link href='https://res.cloudinary.com/dlj3bvob0/image/upload/v1658402693/Android_icon_1_wrzpkj.png' rel='shortcut icon'>");
  $(".flash_notice").delay(2000).slideUp(300);
  $(".flash_alert").delay(2000).slideUp(300);
  $('#priority').keydown(function(e){
    if (!((e.keyCode > 95 && e.keyCode < 106)
      || (e.keyCode > 47 && e.keyCode < 58)
      || e.keyCode == 8)) {
      return false;
    }
  })
  let socket = new WebSocket(`wss://${gon.host}/cable`);
  socket.onopen = function (event) {
    const subscribe_msg = {
      command: 'subscribe',
      identifier: JSON.stringify({ channel: 'NotificationChannel' }),
    };

    socket.send(JSON.stringify(subscribe_msg));
  };

  socket.onmessage = function (event) {
    const incoming_msg = JSON.parse(event.data);
    if (incoming_msg.type === "ping") { return; } // Ignores pings.

    if (typeof incoming_msg.message != 'undefined') {
      if (incoming_msg.message.content == '') {
        var msg = `<i class="fas fa-photo-video"></i>`;
      }
      else {
        var msg = incoming_msg.message.content;
      }

      if (incoming_msg.message.conversation_id != url.charAt(url.length - 1)) {
        console.log(incoming_msg.message.count + 1)
        $(`#notification_count_${incoming_msg.message.conversation_id}`).html(`+ ${incoming_msg.message.count + 1}`)
        $('#wrapper').prepend(`<div class='notify'><div><p>${incoming_msg.message.user} </p><span>${msg}</span></div></div>`);
        $('.chat-name-notification-block').remove();

        for (let i = 0; i < incoming_msg.message.conversations.length; i++) {
          if (!incoming_msg.message.conversations[i].count == 0){
            $('.active-admin-chat__conversations-list').append(`<div class="chat-name-notification-block"><a href="/admin/chat/${incoming_msg.message.conversations[i].id}"><li id="conversation-${incoming_msg.message.conversations[i].id}" class="active-admin-chat__conversation-item ">${incoming_msg.message.conversations[i].email}<span id="notification_count_${incoming_msg.message.conversations[i].id}" ,  class="notification_count">+ ${incoming_msg.message.conversations[i].count}</span></li></a></div>`)
          }
          else {
            $('.active-admin-chat__conversations-list').append(`<div class="chat-name-notification-block"><a href="/admin/chat/${incoming_msg.message.conversations[i].id}"><li id="conversation-${incoming_msg.message.conversations[i].id}" class="active-admin-chat__conversation-item ">${incoming_msg.message.conversations[i].email}<span id="notification_count_${incoming_msg.message.conversations[i].id}" ,  class="notification_count"></span></li></a></div>`)

          }
        }
      }
      else {
        console.log('in else part')
        $.ajax({
          url: "/admin/messages/read_message",
          type: "GET",
          dataType: 'script',
          data: { conversation_id: incoming_msg.message.conversation_id }
        })
      }
    }

    $(".notify").delay(2000).slideUp(100);
  };
})
