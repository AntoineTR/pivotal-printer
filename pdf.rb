#!/usr/bin/env ruby

# Script to generate PDF cards suitable for planning poker
# from Pivotal Tracker [http://www.pivotaltracker.com/] CSV export.

# Inspired by Bryan Helmkamp's http://github.com/brynary/features2cards/

# Example output: http://img.skitch.com/20100522-d1kkhfu6yub7gpye97ikfuubi2.png

require 'rubygems'
require 'csv'
require 'ostruct'
require 'term/ansicolor'
require 'prawn'
require 'prawn/layout/grid'

class String; include Term::ANSIColor; end

def get_cards_file(cards)
  pdf = Prawn::Document.new({
      :page_layout => :landscape,
      :margin      => [25, 25, 50, 25],
      :page_size   => 'A4'
    })
  
  @num_cards_on_page = 0
  pdf.font "Courier"
  
  cards.each_with_index do |card, i|
    # --- Split pages
    if i > 0 and i % 4 == 0
      pdf.start_new_page
      @num_cards_on_page  = 1
    else
      @num_cards_on_page += 1
    end
    
    # --- Define 2x2 grid
    pdf.define_grid(:columns => 2, :rows => 2, :gutter => 42)
    
    row    = (@num_cards_on_page+1) / 4
    column = i % 2
    padding = 12

    cell = pdf.grid( row, column )
    cell.bounding_box do

      pdf.stroke_color = "666666"
      pdf.stroke_bounds
      
      # --- Write content
      pdf.bounding_box [pdf.bounds.left+padding, pdf.bounds.top-padding], :width => cell.width-padding*2 do
        pdf.text card.name, :size => 14
        pdf.text "\n", :size => 14
        pdf.fill_color "444444"
        pdf.text card.description, :size => 10
        pdf.fill_color "000000"
      end
      
      pdf.text_box "Points: " + card.estimate.to_s,
      :size => 12, :at => [12, 50], :width => cell.width-18
      pdf.text_box "Labels: " + (card.labels.nil? ? '' : card.labels),
      :size => 8, :at => [12, 18], :width => cell.width-18
      
      pdf.fill_color "999999"
      pdf.text_box card.story_type.capitalize,  :size => 8,  :align => :right, :at => [12, 18], :width => cell.width-18
      pdf.fill_color "000000"
      
    end
    
  end # each cards
  pdf.number_pages "<page>/<total>", {:align => :center}
  
  pdf.render
end
