{
  enable = true;
  settings = {
    feed_list_focused_width = "33%";
    article_list_focused_width = "85%";
    article_list_focused_height = "66%";
    article_content_focused_height = "80%";

    feed_list = ["feeds" "* categories" "tags"];

    after_sync_commands = ["collapse all" "expandcategories unread"];

    share_targets = [
      "clipboard"
    ];

    icon_set = {
      preset = "nerd";
      url = "#";
      image = "*";
    };

    input_config.mappings = {
      "C-s" = ["pipe md null ~/.config/eilmeldung/save-article.sh \"{feed}\" \"{date}\" \"{title}\""];
    };
  };
}
