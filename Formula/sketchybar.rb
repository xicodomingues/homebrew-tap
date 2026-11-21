# typed: false

# frozen_string_literal: true

# sketchybar.rb — fork of felixkratz/formulae/sketchybar
class Sketchybar < Formula
  env :std
  desc "Custom macOS statusbar with shell plugin, interaction and graph support"
  homepage "https://github.com/FelixKratz/SketchyBar"
  # Upstream v2.24.1 plus two patches: create item windows only where the item is
  # drawn (cold start 10s -> 0.7s with 142 items on 3 displays), and upstream PR #892
  # (the bar rises above macOS 27's hidden-menu-bar strip so clicks reach it). Bump
  # `revision` and `branch` to a new lazy-item-windows-<version> branch cut from the release tag.
  url "https://github.com/xicodomingues/SketchyBar.git",
      branch:   "lazy-item-windows-2.24.1",
      revision: "5e50e3a11807e0a48009a8acaf61ae976de2698e"
  version "2.24.1"
  license "GPL-3.0-only"
  revision 1
  head "https://github.com/xicodomingues/SketchyBar.git", branch: "lazy-item-windows-2.24.1"

  def clear_env
    ENV.delete("CFLAGS")
    ENV.delete("LDFLAGS")
    ENV.delete("CXXFLAGS")
  end

  def install
    clear_env
    (var/"log/sketchybar").mkpath
    if MacOS.version < 11
      system "make", "x86"
    else
      system "make"
    end

    system "codesign", "--force", "-s", "-", "#{buildpath}/bin/sketchybar"
    bin.install "#{buildpath}/bin/sketchybar"
    (pkgshare/"examples").install "#{buildpath}/sketchybarrc"
    (pkgshare/"examples").install "#{buildpath}/plugins/"

    # Install documentation files
    man.mkpath
    system "curl", "https://felixkratz.github.io/SketchyBar/documentation.tar.gz", "-o", "#{buildpath}/documentation.tar.gz"
    system "tar", "-xzvf", "#{buildpath}/documentation.tar.gz", "-C", "#{buildpath}/"
    man1.install "#{buildpath}/sketchybar.1"
    man5.install "#{buildpath}/sketchybar.5"
    man5.install "#{buildpath}/sketchybar-animate.5"
    man5.install "#{buildpath}/sketchybar-components.5"
    man5.install "#{buildpath}/sketchybar-events.5"
    man5.install "#{buildpath}/sketchybar-items.5"
    man5.install "#{buildpath}/sketchybar-popup.5"
    man5.install "#{buildpath}/sketchybar-query.5"
    man5.install "#{buildpath}/sketchybar-tips.5"
    man5.install "#{buildpath}/sketchybar-types.5"
  end

  def caveats
    <<~EOS
      Copy the example configuration into your home directory and make the scripts executable:
        mkdir -p ~/.config/sketchybar/plugins
        cp #{opt_pkgshare}/examples/sketchybarrc ~/.config/sketchybar/sketchybarrc
        cp -r #{opt_pkgshare}/examples/plugins/ ~/.config/sketchybar/plugins/
        chmod +x ~/.config/sketchybar/plugins/*
    EOS
  end

  service do
    run "#{opt_bin}/sketchybar"
    environment_variables PATH: std_service_path_env, LANG: "en_US.UTF-8"
    keep_alive true
    process_type :interactive
    log_path "#{var}/log/sketchybar/sketchybar.out.log"
    error_log_path "#{var}/log/sketchybar/sketchybar.err.log"
  end

  test do
    echo "To test your installation run: sketchybar -v \n"
  end
end
