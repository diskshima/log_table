#
# 201512010063205_create_users.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
