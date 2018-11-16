//
//  AnalyticsViewController.swift
//  iOS
//
//  Created by Nil Puig on 16/11/2018.
//  Copyright © 2018 Nil Puig. All rights reserved.
//

import UIKit
import Charts

class AnalyticsViewController: UIViewController, UIScrollViewDelegate {

  var currentVisibleView: UIView?


  override func viewDidLoad() {
    super.viewDidLoad()

    setupNav()
    setupViews()
    baseScrollView.delegate = self

    setupPieChart()
    barChartSetup()
    horizontalBarChartSetup()
    lineChartSetup()
    duoLineChartSetup()
  }

  func setupNav() {
    self.navigationController?.navigationBar.barTintColor = UIColor.mainMedium
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationItem.title = "Analytics"
    let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = textAttributes
    self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
    self.navigationController?.navigationBar.layer.shadowOpacity = 0.2
    self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.navigationController?.navigationBar.layer.shadowRadius = 1
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if baseScrollView.isDecelerating == false {
      startAnimation()
    }
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    startAnimation()
  }

  func startAnimation() {
    let barGraphFrame: CGRect = self.barGraphContainer.frame
    let horizontalGraphFrame: CGRect = self.horizontalBarGraphContainer.frame
    let singleLineGraphFrame: CGRect = self.singleLineGraphContainer.frame
    let duoLineGraphFrame: CGRect = self.duoLineGraphContainer.frame
    let pieChartFrame: CGRect = self.pieChartContainer.frame

    let scrollingContainer: CGRect = CGRect(x: 0, y: baseScrollView.contentOffset.y + 200, width: baseScrollView.frame.size.width, height: baseScrollView.frame.size.height)

    if(scrollingContainer.intersects(barGraphFrame)) {
      myBarGraphView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutBack)
    }
    else if(scrollingContainer.intersects(horizontalGraphFrame)) {
      myHorizontalGraphView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutCubic)
    }
    else if(scrollingContainer.intersects(singleLineGraphFrame)) {
      mySingleLineGraphView.animate(yAxisDuration: 1.0, easingOption: .easeOutSine)
    }
    else if(scrollingContainer.intersects(duoLineGraphFrame)) {
      myDuoLineGraphView.animate(xAxisDuration: 1.0, easingOption: .linear)
    }
    else if(scrollingContainer.intersects(pieChartFrame)) {
      myPieChartView.animate(yAxisDuration: 1.0, easingOption: .easeInExpo)
    }
  }

  func getRandomNum () -> Double {
    return Double(Int.random(in: 5 ..< 25))
  }


  func setupPieChart() {
    let eurDataEntry = PieChartDataEntry(value: getRandomNum(), label: "EUR")
    let usdDataEntry = PieChartDataEntry(value: getRandomNum(), label: "USD")
    let gbpDataEntry = PieChartDataEntry(value: getRandomNum(), label: "GBP")
    let othersDataEntry = PieChartDataEntry(value: getRandomNum(), label: "others")

    let pieChartDataEntries = [eurDataEntry, usdDataEntry, gbpDataEntry, othersDataEntry]

    let chartDataSet = PieChartDataSet(values: pieChartDataEntries, label: "")

    let data = PieChartData(dataSet: chartDataSet)
    myPieChartView.data = data

    chartDataSet.colors = ChartColorTemplates.material()

    myPieChartView.notifyDataSetChanged()
  }

  func barChartSetup() {
    let entry1 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry2 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry3 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry4 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry5 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())

    let dataSet = BarChartDataSet(values: [entry1, entry2, entry3, entry4, entry5], label: "" )

    let data = BarChartData(dataSets: [dataSet])
    myBarGraphView.data = data
    myBarGraphView.chartDescription?.text = ""

    dataSet.colors = ChartColorTemplates.joyful()

    myBarGraphView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutBack)

    myBarGraphView.notifyDataSetChanged()
  }


  func horizontalBarChartSetup() {
    let entry1 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry2 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())
    let entry3 = BarChartDataEntry(x: getRandomNum(), y: getRandomNum())

    let dataSet = BarChartDataSet(values: [entry1, entry2, entry3], label: "")

    let data = BarChartData(dataSets: [dataSet])
    myHorizontalGraphView.data = data

    myHorizontalGraphView.chartDescription?.text = ""
    dataSet.colors = ChartColorTemplates.liberty()


    myHorizontalGraphView.notifyDataSetChanged()
  }


  func lineChartSetup() {
    var val: Double = 0.0
    let values = (0..<10).map { (i) -> ChartDataEntry in
      val += getRandomNum()
      return ChartDataEntry(x: Double(i), y: val)
    }

    let dataset = LineChartDataSet(values: values, label: "")

    let data = LineChartData(dataSet: dataset)
    mySingleLineGraphView.data = data

    dataset.circleColors = [NSUIColor.black]
    dataset.colors = ChartColorTemplates.colorful()
    dataset.lineWidth = 3
    dataset.circleRadius = 2

    mySingleLineGraphView.notifyDataSetChanged()
  }


  func duoLineChartSetup() {
    let line_1_values = (0..<5).map { (i) -> ChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(11)))
      return ChartDataEntry(x: Double(i), y: val)
    }

    let line_2_values = (0..<5).map { (i) -> ChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(11)))
      return ChartDataEntry(x: Double(i), y: val)
    }

    let dataset = LineChartDataSet(values: line_1_values, label: "Losses")
    let dataset2 = LineChartDataSet(values: line_2_values, label: "Profits")


    let data = LineChartData(dataSets: [dataset, dataset2])
    myDuoLineGraphView.data = data

    dataset.colors = [NSUIColor.red]
    dataset.circleColors = [NSUIColor.black]
    dataset.lineWidth = 2

    dataset2.colors = [NSUIColor.green]
    dataset2.circleColors = [NSUIColor.darkGray]
    dataset2.lineWidth = 2

    myDuoLineGraphView.notifyDataSetChanged()
  }

  var baseScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = UIColor.clear
    return scrollView
  }()

  var baseStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 30
    return stackView
  }()


  var barGraphContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
    return view
  }()

  var myBarGraphView: BarChartView = {
    let view = BarChartView()
    view.legend.enabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var horizontalBarGraphContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
    return view
  }()

  var myHorizontalGraphView: HorizontalBarChartView = {
    let view = HorizontalBarChartView()
    view.legend.enabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var singleLineGraphContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
    return view
  }()

  var mySingleLineGraphView: LineChartView = {
    let view = LineChartView()
    view.legend.enabled = false
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  var duoLineGraphContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
    return view
  }()

  var myDuoLineGraphView: LineChartView = {
    let view = LineChartView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()


  var pieChartContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white
    view.layer.cornerRadius = 10
    view.layer.masksToBounds = true
    return view
  }()

  var myPieChartView: PieChartView = {
    let view = PieChartView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()


  private func setupViews() {
    view.backgroundColor = .white

    view.addSubview(baseScrollView)
    baseScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
    baseScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
    baseScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 2).isActive = true
    baseScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true

    baseScrollView.addSubview(baseStackView)
    baseStackView.topAnchor.constraint(equalTo: baseScrollView.topAnchor, constant: 5).isActive = true
    baseStackView.bottomAnchor.constraint(equalTo: baseScrollView.bottomAnchor).isActive = true
    baseStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    baseStackView.centerXAnchor.constraint(equalTo: baseScrollView.centerXAnchor).isActive = true


    addPieChartGraphViews()

    addSingleLineGraphViews()

    addBarGraphViews()

    addHorizontalBarGraphViews()

    addDuoLineGraphViews()
  }


  private func addBarGraphViews() {
    baseStackView.addArrangedSubview(barGraphContainer)
    barGraphContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true

    let headingLabel = UILabel()
    headingLabel.translatesAutoresizingMaskIntoConstraints = false
    headingLabel.text = "Porfolio"
    headingLabel.textAlignment = .center
    headingLabel.font = UIFont.boldSystemFont(ofSize: 18)

    barGraphContainer.addSubview(headingLabel)
    headingLabel.widthAnchor.constraint(equalTo: barGraphContainer.widthAnchor).isActive = true
    headingLabel.heightAnchor.constraint(equalTo: barGraphContainer.heightAnchor, multiplier: 0.15).isActive = true
    headingLabel.centerXAnchor.constraint(equalTo: barGraphContainer.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: barGraphContainer.topAnchor, constant: 15).isActive = true

    barGraphContainer.addSubview(myBarGraphView)
    myBarGraphView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 15).isActive = true
    myBarGraphView.bottomAnchor.constraint(equalTo: barGraphContainer.bottomAnchor, constant: 5).isActive = true
    myBarGraphView.heightAnchor.constraint(equalTo: barGraphContainer.heightAnchor, multiplier: 0.8, constant: -20).isActive = true
    myBarGraphView.widthAnchor.constraint(equalTo: barGraphContainer.widthAnchor, multiplier: 0.95).isActive = true
    myBarGraphView.centerXAnchor.constraint(equalTo: barGraphContainer.centerXAnchor).isActive = true
  }


  private func addHorizontalBarGraphViews() {
    baseStackView.addArrangedSubview(horizontalBarGraphContainer)
    horizontalBarGraphContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true

    let headingLabel = UILabel()
    headingLabel.translatesAutoresizingMaskIntoConstraints = false
    headingLabel.text = "Horizontal Graphs"
    headingLabel.textAlignment = .center
    headingLabel.font = UIFont.boldSystemFont(ofSize: 18)

    horizontalBarGraphContainer.addSubview(headingLabel)
    headingLabel.widthAnchor.constraint(equalTo: horizontalBarGraphContainer.widthAnchor).isActive = true
    headingLabel.heightAnchor.constraint(equalTo: horizontalBarGraphContainer.heightAnchor, multiplier: 0.15).isActive = true
    headingLabel.centerXAnchor.constraint(equalTo: horizontalBarGraphContainer.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: horizontalBarGraphContainer.topAnchor, constant: 5).isActive = true

    horizontalBarGraphContainer.addSubview(myHorizontalGraphView)
    myHorizontalGraphView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 5).isActive = true
    myHorizontalGraphView.bottomAnchor.constraint(equalTo: horizontalBarGraphContainer.bottomAnchor, constant: -5).isActive = true
    myHorizontalGraphView.heightAnchor.constraint(equalTo: horizontalBarGraphContainer.heightAnchor, multiplier: 0.8, constant: -24).isActive = true
    myHorizontalGraphView.widthAnchor.constraint(equalTo: horizontalBarGraphContainer.widthAnchor, multiplier: 0.95).isActive = true
    myHorizontalGraphView.centerXAnchor.constraint(equalTo: horizontalBarGraphContainer.centerXAnchor).isActive = true
  }


  func addSingleLineGraphViews() {
    baseStackView.addArrangedSubview(singleLineGraphContainer)
    singleLineGraphContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true

    let headingLabel = UILabel()
    headingLabel.translatesAutoresizingMaskIntoConstraints = false
    headingLabel.text = "Stock Price"
    headingLabel.textAlignment = .center
    headingLabel.font = UIFont.boldSystemFont(ofSize: 18)

    singleLineGraphContainer.addSubview(headingLabel)
    headingLabel.widthAnchor.constraint(equalTo: singleLineGraphContainer.widthAnchor).isActive = true
    headingLabel.heightAnchor.constraint(equalTo: singleLineGraphContainer.heightAnchor, multiplier: 0.15).isActive = true
    headingLabel.centerXAnchor.constraint(equalTo: singleLineGraphContainer.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: singleLineGraphContainer.topAnchor, constant: 5).isActive = true

    singleLineGraphContainer.addSubview(mySingleLineGraphView)
    mySingleLineGraphView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 5).isActive = true
    mySingleLineGraphView.bottomAnchor.constraint(equalTo: singleLineGraphContainer.bottomAnchor, constant: -5).isActive = true
    mySingleLineGraphView.heightAnchor.constraint(equalTo: singleLineGraphContainer.heightAnchor, multiplier: 0.8, constant: -24).isActive = true
    mySingleLineGraphView.widthAnchor.constraint(equalTo: singleLineGraphContainer.widthAnchor, multiplier: 0.95).isActive = true
    mySingleLineGraphView.centerXAnchor.constraint(equalTo: singleLineGraphContainer.centerXAnchor).isActive = true
  }


  func addDuoLineGraphViews() {
    baseStackView.addArrangedSubview(duoLineGraphContainer)
    duoLineGraphContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true

    let headingLabel = UILabel()
    headingLabel.translatesAutoresizingMaskIntoConstraints = false
    headingLabel.text = "Losses Vs Profits"
    headingLabel.textAlignment = .center
    headingLabel.font = UIFont.boldSystemFont(ofSize: 18)

    duoLineGraphContainer.addSubview(headingLabel)
    headingLabel.widthAnchor.constraint(equalTo: duoLineGraphContainer.widthAnchor).isActive = true
    headingLabel.heightAnchor.constraint(equalTo: duoLineGraphContainer.heightAnchor, multiplier: 0.15).isActive = true
    headingLabel.centerXAnchor.constraint(equalTo: duoLineGraphContainer.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: duoLineGraphContainer.topAnchor, constant: 5).isActive = true

    duoLineGraphContainer.addSubview(myDuoLineGraphView)
    myDuoLineGraphView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 5).isActive = true
    myDuoLineGraphView.bottomAnchor.constraint(equalTo: duoLineGraphContainer.bottomAnchor, constant: -5).isActive = true
    myDuoLineGraphView.heightAnchor.constraint(equalTo: duoLineGraphContainer.heightAnchor, multiplier: 0.8, constant: -20).isActive = true
    myDuoLineGraphView.widthAnchor.constraint(equalTo: duoLineGraphContainer.widthAnchor, multiplier: 0.95).isActive = true
    myDuoLineGraphView.centerXAnchor.constraint(equalTo: duoLineGraphContainer.centerXAnchor).isActive = true
  }


  func addPieChartGraphViews() {
    baseStackView.addArrangedSubview(pieChartContainer)
    pieChartContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true

    let headingLabel = UILabel()
    headingLabel.translatesAutoresizingMaskIntoConstraints = false
    headingLabel.text = "Balance"
    headingLabel.textAlignment = .center
    headingLabel.font = UIFont.boldSystemFont(ofSize: 18)

    pieChartContainer.addSubview(headingLabel)
    headingLabel.widthAnchor.constraint(equalTo: pieChartContainer.widthAnchor).isActive = true
    headingLabel.heightAnchor.constraint(equalTo: pieChartContainer.heightAnchor, multiplier: 0.2).isActive = true
    headingLabel.centerXAnchor.constraint(equalTo: pieChartContainer.centerXAnchor).isActive = true
    headingLabel.topAnchor.constraint(equalTo: pieChartContainer.topAnchor, constant: 0).isActive = true

    pieChartContainer.addSubview(myPieChartView)
    myPieChartView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 0).isActive = true
    myPieChartView.bottomAnchor.constraint(equalTo: pieChartContainer.bottomAnchor, constant: -5).isActive = true
    myPieChartView.heightAnchor.constraint(equalTo: pieChartContainer.heightAnchor, multiplier: 0.9, constant: -20).isActive = true
    myPieChartView.widthAnchor.constraint(equalTo: pieChartContainer.widthAnchor, multiplier: 0.9).isActive = true
    myPieChartView.centerXAnchor.constraint(equalTo: pieChartContainer.centerXAnchor).isActive = true
  }








}
